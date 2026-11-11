import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/helpers/web_view_container.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';

/// نتيجة صفحة بوابة الدفع من ناحية العميل
enum GatewayPaymentOutcome {
  /// الطلب اتدفع (isPaid)
  paid,

  /// البوابة رجعت فشل
  failed,

  /// الصفحة وصلت لصفحة الرجوع بس النتيجة لسه ماوصلتش السيرفر
  processing,

  /// العميل خرج من الصفحة قبل ما يدفع
  left,
}

class GatewayPaymentResult {
  final GatewayPaymentOutcome outcome;

  /// آخر نسخة من الطلب بعد ما الصفحة قفلت، null لو مقدرناش نجيبها
  final OrderModel? order;

  const GatewayPaymentResult(this.outcome, this.order);
}

/// صفحة بوابة الدفع (TLync) في WebView، مشتركة بين تأكيد الطلب والدفع من
/// تفاصيل الطلب. الصفحة بتقفل لما توصل لـ api/payments/tlync/return، أو لما
/// النتيجة توصل من OrderUpdated الأول، من غير polling. بعدها بنجيب الطلب من
/// السيرفر عشان النتيجة الحقيقية مش اللي في اللينك
abstract final class GatewayPayment {
  static Future<GatewayPaymentResult> open(
    BuildContext context, {
    required int orderId,
    required String url,
  }) async {
    final updates = getIt<OrderUpdates>();
    final closeSignal = ValueNotifier<String?>(null);
    OrderModel? latest;

    // الطلب ده متابَع وصفحته مفتوحة، فالـ realtime مابيعرضش عليه تنبيه فوقها
    updates.watch(orderId);
    final subscription = updates.orders.listen((order) {
      if (order.id != orderId) return;
      latest = order;
      if (order.isPaid || order.paymentStatus == PaymentStatus.failed) {
        closeSignal.value = 'realtime';
      }
    });

    final finishedAt = await context.push<String>(
      AppRouter.webViewContainer,
      extra: WebViewArgs(
        url: url,
        title: 'payment',
        finishUrls: const [Endpoints.paymentReturn],
        closeSignal: closeSignal,
      ),
    );

    await subscription.cancel();
    updates.unwatch(orderId);
    closeSignal.dispose();

    final fresh = await getIt<OrdersDataSource>().getOrderDetails(orderId);
    final order = fresh.fold((_) => latest, (order) => order);
    // الليستة وشاشة الانتظار والتفاصيل يجيبوا الحالة الجديدة
    updates.notify(orderId);

    final GatewayPaymentOutcome outcome;
    if (order?.isPaid ?? false) {
      outcome = GatewayPaymentOutcome.paid;
    } else if (finishedAt == null) {
      outcome = GatewayPaymentOutcome.left;
    } else if (order?.paymentStatus == PaymentStatus.failed) {
      outcome = GatewayPaymentOutcome.failed;
    } else {
      outcome = GatewayPaymentOutcome.processing;
    }
    return GatewayPaymentResult(outcome, order);
  }

  /// رسالة النتيجة. [leftMessageKey] لو العميل خرج من غير ما يدفع،
  /// و null يعني مانقولش حاجة (زرار الدفع لسه قدامه في التفاصيل)
  static void showOutcome(
    BuildContext context,
    GatewayPaymentResult result, {
    String? leftMessageKey,
  }) {
    switch (result.outcome) {
      case GatewayPaymentOutcome.paid:
        context.showSuccessMessage('payment_success'.tr());
      case GatewayPaymentOutcome.failed:
        context.showErrorMessage('payment_failed_message'.tr());
      case GatewayPaymentOutcome.processing:
        context.showSuccessMessage(
          'payment_processing'.tr(),
          color: AppColors.orangeColor,
          icon: Icons.schedule_rounded,
        );
      case GatewayPaymentOutcome.left:
        if (leftMessageKey != null) {
          context.showSuccessMessage(
            leftMessageKey.tr(),
            color: AppColors.orangeColor,
            icon: Icons.info_outline_rounded,
          );
        }
    }
  }
}
