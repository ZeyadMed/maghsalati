import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_action_button.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_details_card.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/pending_status_header.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_details_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';

/// شاشة انتظار موافقة المغسلة، بتتفتح بعد ما تدوس تأكيد الطلب
/// بتتابع حالة الطلب الحقيقية: كل شوية بتسأل السيرفر، وكمان بتتحدث على طول
/// لما ييجي إشعار عن الطلب. أول ما المغسلة تقبل أو ترفض بتروح للشاشة المناسبة
/// كل المحتوى في نص الشاشة، ولو الطلب طويل بيبقى قابل للسكرول
class OrederPending extends StatefulWidget {
  final PendingOrderModel order;

  const OrederPending({super.key, required this.order});

  @override
  State<OrederPending> createState() => _OrederPendingState();
}

class _OrederPendingState extends State<OrederPending>
    with WidgetsBindingObserver {
  /// الإشعار هو اللي بيحرك الشاشة غالبًا، والسؤال ده احتياطي لو الإشعار ماوصلش
  static const Duration _pollInterval = Duration(seconds: 15);

  final OrderDetailsCubit _cubit = getIt<OrderDetailsCubit>();
  Timer? _pollTimer;
  StreamSubscription<int?>? _updatesSubscription;

  /// عشان مانفتحش شاشة النتيجة مرتين لو ردين وصلوا ورا بعض
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    // من غير رقم الطلب مانقدرش نتابعه، فالشاشة بتفضل تعرض زرار طلباتي بس
    if (!widget.order.hasOrderId) return;

    WidgetsBinding.instance.addObserver(this);
    _cubit.load(widget.order.orderId);
    _pollTimer = Timer.periodic(_pollInterval, (_) => _cubit.refresh());
    _updatesSubscription = getIt<OrderUpdates>().stream.listen((orderId) {
      if (orderId == null || orderId == widget.order.orderId) _cubit.refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cubit.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _updatesSubscription?.cancel();
    _cubit.close();
    super.dispose();
  }

  /// أي حالة بعد "جديدة" غير الرفض والإلغاء معناها إن المغسلة قبلت
  /// و pushReplacement عشان لو رجع مايرجعش للانتظار
  void _onOrderLoaded(OrderModel order) {
    if (_resultShown || order.status == OrderStatus.newOrder) return;
    _resultShown = true;
    _pollTimer?.cancel();
    context.pushReplacement(
      order.status == OrderStatus.rejected ||
              order.status == OrderStatus.cancelled
          ? AppRouter.rejectOrder
          : AppRouter.confirmOrder,
      extra: widget.order,
    );
  }

  /// بيفتح تفاصيل الطلب، ولو رقمه مش معروف بيرجع للرئيسية ويلاقيه في تاب طلباتي
  void _followOrder() {
    if (widget.order.hasOrderId) {
      context.push(
        AppRouter.orderDetails,
        extra: OrderDetailsArgs(orderId: widget.order.orderId),
      );
    } else {
      context.go(AppRouter.initialRoot);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailsCubit, BaseState<OrderModel>>(
      bloc: _cubit,
      listenWhen: (previous, current) =>
          current.isSuccess && current.data != null,
      listener: (context, state) => _onOrderLoaded(state.data!),
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                // المحتوى بيتوسط رأسيًا، ولو طول عن الشاشة بيسكرول عادي
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PendingStatusHeader(
                        laundryName: widget.order.laundryName,
                      ),
                      Gap(28.h),
                      OrderDetailsCard(order: widget.order),
                      Gap(28.h),
                      OrderActionButton(
                        label: widget.order.hasOrderId
                            ? 'follow_order'.tr()
                            : 'back_to_home'.tr(),
                        onPressed: _followOrder,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
