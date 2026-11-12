import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/confirm_cart_bottom_sheet.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/gateway_payment.dart';

/// إتمام الطلب من السلة، نفس الخطوات من تاب السلة وشيت السلة في المغسلة:
/// 1. تفاصيل الطلب (العنوان واللي هيسلّم وطريقة الدفع) بتبعت confirm، من
///    تاب السلة على طول أو من شيت التأكيد ([start])
/// 2. لو بالبوابة: صفحة الدفع بتتفتح على طول
/// 3. الطلب اتدفع (محفظة أو بوابة) → شاشة انتظار موافقة المغسلة
///    لسه مادفعش (خرج من البوابة أو النتيجة لسه) → تفاصيل الطلب وفيها زرار الدفع،
///    لأن الطلب مش ظاهر للمغسلة لحد الدفع فمفيش حاجة يستناها
abstract final class CheckoutFlow {
  /// [beforeNavigate] بيتنادى قبل ما نفتح الشاشة الجاية، زي قفل شاشة القطع
  static Future<void> start(
    BuildContext context, {
    VoidCallback? beforeNavigate,
  }) async {
    final confirmed = await ConfirmCartBottomSheet.show(context);
    if (confirmed == null || !context.mounted) return;
    await proceed(
      context,
      confirmed.cart,
      confirmed.order,
      beforeNavigate: beforeNavigate,
    );
  }

  /// الطلب اتأكد (من الشيت أو من تاب السلة على طول): البوابة لو محتاجها،
  /// وبعدين شاشة الانتظار أو تفاصيل الطلب. [cart] السلة وقت التأكيد
  static Future<void> proceed(
    BuildContext context,
    CartModel cart,
    OrderModel order, {
    VoidCallback? beforeNavigate,
  }) async {
    var current = order;
    if (order.status == OrderStatus.pendingPayment && order.hasPaymentUrl) {
      final result = await GatewayPayment.open(
        context,
        orderId: order.id,
        url: order.paymentUrl!,
      );
      if (!context.mounted) return;
      current = result.order ?? order;
      GatewayPayment.showOutcome(
        context,
        result,
        leftMessageKey: 'order_saved_awaiting_payment',
      );
    }

    beforeNavigate?.call();
    if (current.status == OrderStatus.pendingPayment) {
      context.push(
        AppRouter.orderDetails,
        extra: OrderDetailsArgs.fromOrder(current),
      );
    } else {
      context.push(
        AppRouter.orderPending,
        extra: cart.toPendingOrder(orderId: current.id),
      );
    }
  }
}
