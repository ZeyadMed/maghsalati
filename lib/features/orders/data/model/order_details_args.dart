import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// اللي بيتبعت لشاشة تفاصيل الطلب في state.extra
/// الرقم لوحده كفاية (زي لما تتفتح من إشعار)، والطلب اللي جاي من الليستة
/// بيتعرض على طول لحد ما التفاصيل توصل من السيرفر
class OrderDetailsArgs {
  final int orderId;
  final OrderModel? order;

  /// رقم رحلة التسليم لو جاي من إشعار وصول المندوب،
  /// بيتستخدم لو تفاصيل الطلب مابترجعش رحلة التسليم
  final int? deliveryTripId;

  const OrderDetailsArgs({
    required this.orderId,
    this.order,
    this.deliveryTripId,
  });

  factory OrderDetailsArgs.fromOrder(OrderModel order) =>
      OrderDetailsArgs(orderId: order.id, order: order);
}
