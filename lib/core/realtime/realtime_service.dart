import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/helpers/logger.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/token_refresh_service.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';
import 'package:maghsalati/main.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// حالة اتصال الـ hub، والبوتوم ناف بيعرض "جاري إعادة الاتصال" وقت [reconnecting]
enum RealtimeStatus { disconnected, connecting, connected, reconnecting }

/// اتصال SignalR واحد للتطبيق كله على hubs/orders، السيرفر بيبعت والعميل بيسمع بس
/// - OrderUpdated (OrderDto): أي تغيير في طلب العميل، بيتبعت لـ [OrderUpdates.publish]
/// - AdjustmentCreated (OrderAdjustmentDto): المغسلة بعتت تعديل،
///   بيتبعت لـ [OrderUpdates.adjustmentCreated]
/// الأحداث اللي فاتت واحنا مش متوصلين مابترجعش، فبعد أي reconnect
/// بنقول للشاشات تجيب من السيرفر تاني ([OrderUpdates.notify])
/// ولو الطلب مش مفتوح قدام اليوزر بنعرض تنبيه صغير جوه الأبلكيشن،
/// لأن إشعار الـ FCM مابيتعرضش واحنا متوصلين (عشان مايبقاش تنبيهين)
class RealtimeService {
  static const String _orderUpdated = 'OrderUpdated';
  static const String _adjustmentCreated = 'AdjustmentCreated';

  final TokenRefreshService _refreshService;
  final OrderUpdates _orderUpdates;

  RealtimeService(this._refreshService, this._orderUpdates);

  final ValueNotifier<RealtimeStatus> status = ValueNotifier(
    RealtimeStatus.disconnected,
  );

  HubConnection? _hub;
  Future<void>? _starting;

  /// اتوصلنا قبل كده في الجلسة دي، فأي اتصال بعده محتاج re-sync
  bool _hadConnection = false;

  /// آخر حالة شفناها لكل طلب، عشان التنبيه مايتكررش لنفس التغيير
  final Map<int, (OrderStatus, PaymentStatus, bool)> _lastSeen = {};

  /// AdjustmentCreated مافيهوش رقم الطلب، بس OrderUpdated بحالة
  /// AdjustmentPendingApproval بيوصل قبله على طول، فبناخد الرقم منه
  int? _lastAdjustmentOrderId;

  bool get isConnected => _hub?.state == HubConnectionState.Connected;

  /// بتتنادى من البوتوم ناف (بعد اللوجين أو من السبلاش لو فيه جلسة)
  /// ولما الأبلكيشن يرجع من الخلفية، ولو متوصلين أو بنتوصل مابتعملش حاجة
  Future<void> start() {
    // متوصلين، أو الـ automatic reconnect شغال ومينفعش start فوقه
    final state = _hub?.state;
    if (state != null && state != HubConnectionState.Disconnected) {
      return Future.value();
    }
    return _starting ??= _connect().whenComplete(() => _starting = null);
  }

  Future<void> _connect() async {
    if (await CacheManager.isGuestMode()) return;
    final token = await CacheManager.getAccessToken();
    if (token == null || token.isEmpty) return;

    final hub = _hub ??= _buildHub();
    status.value = RealtimeStatus.connecting;
    try {
      await hub.start();
      _onConnected();
    } catch (e) {
      loggerWarn('Realtime connect failed: $e');
      // الـ hub مابيعديش على الانترسبتور، والتوكن بيتشيك وقت الـ handshake بس،
      // فلو خلص بنجدد بنفسنا مرة. أي خطأ تاني (نت، سيرفر) مالوش علاقة بالتوكن
      if (!e.toString().contains('401') || _hub != hub) {
        if (_hub == hub) status.value = RealtimeStatus.disconnected;
        return;
      }
      final refreshed = await _refreshService.refresh();
      if (refreshed is! RefreshSuccess || _hub != hub) {
        if (_hub == hub) status.value = RealtimeStatus.disconnected;
        return;
      }
      try {
        await hub.start();
        _onConnected();
      } catch (e) {
        loggerWarn('Realtime connect failed again: $e');
        if (_hub == hub) status.value = RealtimeStatus.disconnected;
      }
    }
  }

  void _onConnected() {
    logger('Realtime connected');
    status.value = RealtimeStatus.connected;
    if (_hadConnection) _orderUpdates.notify();
    _hadConnection = true;
  }

  HubConnection _buildHub() {
    final hub = HubConnectionBuilder()
        .withUrl(
          '${Endpoints.baseUrl}${Endpoints.ordersHub}',
          options: HttpConnectionOptions(
            // بيتقرا مع كل reconnect عشان ياخد أحدث توكن بعد التجديد
            accessTokenFactory: () async =>
                await CacheManager.getAccessToken() ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();

    // لازم يتسجلوا قبل start()
    hub.on(_orderUpdated, (arguments) => _onOrderUpdated(_payload(arguments)));
    hub.on(
      _adjustmentCreated,
      (arguments) => _onAdjustmentCreated(_payload(arguments)),
    );
    hub.onreconnecting(({error}) {
      loggerWarn('Realtime reconnecting: $error');
      status.value = RealtimeStatus.reconnecting;
    });
    hub.onreconnected(({connectionId}) {
      logger('Realtime reconnected');
      status.value = RealtimeStatus.connected;
      _orderUpdates.notify();
    });
    // بعد ما محاولات الـ reconnect تخلص، والبوتوم ناف بيوصل تاني لما الأبلكيشن يرجع
    hub.onclose(({error}) {
      loggerWarn('Realtime closed: $error');
      if (_hub == hub) status.value = RealtimeStatus.disconnected;
    });
    return hub;
  }

  void _onOrderUpdated(Map<String, dynamic>? json) {
    if (json == null) return;
    final OrderModel order;
    try {
      order = OrderModel.fromJson(json);
    } catch (e) {
      loggerWarn('Realtime OrderUpdated parse failed: $e');
      return;
    }
    if (order.id <= 0) return;
    logger('Realtime OrderUpdated #${order.id} ${order.status.name}');

    if (order.status == OrderStatus.adjustmentPendingApproval) {
      _lastAdjustmentOrderId = order.id;
    }
    final previous = _lastSeen[order.id];
    final current = (
      order.status,
      order.paymentStatus,
      order.awaitsDropoffCode,
    );
    _lastSeen[order.id] = current;

    _orderUpdates.publish(order);

    // شيت التعديل هو التنبيه بتاع الحالة دي، فمانعرضش تنبيه تاني قبله
    if (previous == current ||
        order.status == OrderStatus.adjustmentPendingApproval ||
        _orderUpdates.isWatched(order.id)) {
      return;
    }
    // المندوب وصل باب العميل: الحالة بتفضل OutForDelivery فبننبه بنص مخصوص
    if (order.awaitsDropoffCode && !(previous?.$3 ?? false)) {
      _showBanner(
        'realtime_driver_arrived'.tr(args: [order.reference]),
        actionKey: 'view_details',
        orderId: order.id,
      );
      return;
    }
    final paymentChanged =
        previous != null &&
        previous.$1 == order.status &&
        previous.$2 != order.paymentStatus &&
        order.paymentStatus != PaymentStatus.none;
    final label = paymentChanged
        ? order.paymentStatus.labelKey.tr()
        : order.status.labelKey.tr();
    _showBanner(
      'realtime_order_updated'.tr(args: [order.reference, label]),
      actionKey: 'view_details',
      orderId: order.id,
    );
  }

  void _onAdjustmentCreated(Map<String, dynamic>? json) {
    final orderId = _positive(json?['orderId']) ?? _lastAdjustmentOrderId;
    logger('Realtime AdjustmentCreated for order $orderId');
    if (orderId == null) {
      // من غير رقم الطلب، الشاشات المفتوحة بتجيب من السيرفر وتلاقي الحالة
      _orderUpdates.notify();
      return;
    }
    _orderUpdates.adjustmentCreated(orderId);
    if (_orderUpdates.isWatched(orderId)) return;
    _showBanner(
      'realtime_adjustment_created'.tr(args: ['#$orderId']),
      actionKey: 'review_adjustment',
      orderId: orderId,
    );
  }

  /// تنبيه صغير تحت مع زرار يفتح الطلب، وبيظهر بس والأبلكيشن قدام اليوزر
  void _showBanner(
    String message, {
    required String actionKey,
    required int orderId,
  }) {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            message,
            style: TextStyles.blackLight15.copyWith(color: Colors.black),
          ),
          action: SnackBarAction(
            label: actionKey.tr(),
            onPressed: () => AppRouter.router.push(
              AppRouter.orderDetails,
              extra: OrderDetailsArgs(orderId: orderId),
            ),
          ),
        ),
      );
  }

  /// كل حدث ليه argument واحد بس هو الـ DTO
  Map<String, dynamic>? _payload(List<Object?>? arguments) {
    final payload = arguments == null || arguments.isEmpty
        ? null
        : arguments.first;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    if (payload is String && payload.isNotEmpty) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  int? _positive(Object? value) {
    final number = value is num
        ? value.toInt()
        : int.tryParse('${value ?? ''}');
    return number != null && number > 0 ? number : null;
  }

  /// بتتنادى مع مسح الجلسة (خروج أو انتهاء) عشان الحساب اللي بعده
  /// مايستقبلش أحداث اللي قبله
  Future<void> stop() async {
    final hub = _hub;
    _hub = null;
    _hadConnection = false;
    _lastSeen.clear();
    _lastAdjustmentOrderId = null;
    status.value = RealtimeStatus.disconnected;
    if (hub == null) return;
    try {
      await hub.stop();
    } catch (e) {
      loggerWarn('Realtime stop failed: $e');
    }
  }
}
