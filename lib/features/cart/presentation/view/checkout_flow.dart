import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/confirm_cart_bottom_sheet.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/gateway_payment.dart';

/// إتمام الطلب من السلة، نفس الخطوات من تاب السلة وشيت السلة في المغسلة:
/// 1. شيت التأكيد (العنوان واللي هيسلّم وطريقة الدفع) بيبعت confirm
/// 2. لو بالبوابة: صفحة الدفع بتتفتح على طول
/// 3. الطلب اتدفع (محفظة أو بوابة) → شاشة انتظار موافقة المغسلة
///    لسه مادفعش (خرج من البوابة أو النتيجة لسه) → تفاصيل الطلب وفيها زرار الدفع،
///    لأن الطلب مش ظاهر للمغسلة لحد الدفع فمفيش حاجة يستناها
abstract final class CheckoutFlow {
  /// [beforeNavigate] بيتنادى قبل ما نفتح الشاشة الجاية، زي قفل شاشة القطع
  static Future<void> start(
    BuildContext context,
    CartModel cart, {
    VoidCallback? beforeNavigate,
  }) async {
    final order = await ConfirmCartBottomSheet.show(
      context,
      total: cart.totalPrice,
    );
    if (order == null || !context.mounted) return;

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
