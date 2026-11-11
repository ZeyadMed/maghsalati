import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// اللي بيتبعت لشاشة تفاصيل الطلب في state.extra
/// الرقم لوحده كفاية (زي لما تتفتح من إشعار)، والطلب اللي جاي من الليستة
/// بيتعرض على طول لحد ما التفاصيل توصل من السيرفر
class OrderDetailsArgs {
  final int orderId;
  final OrderModel? order;

  /// جاي من زرار "ادفع" في كارت الطلب، فشيت الدفع بيتفتح أول ما الشاشة تفتح
  final bool openPayment;

  const OrderDetailsArgs({
    required this.orderId,
    this.order,
    this.openPayment = false,
  });

  factory OrderDetailsArgs.fromOrder(
    OrderModel order, {
    bool openPayment = false,
  }) => OrderDetailsArgs(
    orderId: order.id,
    order: order,
    openPayment: openPayment,
  );
}
