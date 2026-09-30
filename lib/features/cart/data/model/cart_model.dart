import 'package:maghsalati/features/cart/data/model/cart_item_model.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';

/// سلة العميل زي ما السيرفر شايفها، كل الأسعار والإجماليات محسوبة من عنده
class CartModel {
  final int laundryId;
  final String laundryName;
  final List<CartItemModel> items;
  final num itemsTotal;
  final num deliveryDistanceKm;
  final num pickupFee;
  final num dropoffFee;
  final num totalPrice;

  const CartModel({
    required this.laundryId,
    required this.laundryName,
    required this.items,
    required this.itemsTotal,
    required this.deliveryDistanceKm,
    required this.pickupFee,
    required this.dropoffFee,
    required this.totalPrice,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      laundryId: (json['laundryId'] as num?)?.toInt() ?? 0,
      laundryName: json['laundryName']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList(),
      itemsTotal: json['itemsTotal'] as num? ?? 0,
      deliveryDistanceKm: json['deliveryDistanceKm'] as num? ?? 0,
      pickupFee: json['pickupFee'] as num? ?? 0,
      dropoffFee: json['dropoffFee'] as num? ?? 0,
      totalPrice: json['totalPrice'] as num? ?? 0,
    );
  }

  bool get isEmpty => items.isEmpty;

  /// إجمالي عدد القطع (مش عدد السطور)
  int get totalPieces => items.fold(0, (sum, item) => sum + item.quantity);

  /// عدد القطع اللي في السلة من القطع دي بس، زي قطع قسم معين
  int piecesOf(Iterable<int> laundryServiceItemIds) {
    final ids = laundryServiceItemIds.toSet();
    return items
        .where((item) => ids.contains(item.laundryServiceItemId))
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /// رسوم الاستلام + رسوم التسليم
  num get deliveryFees => pickupFee + dropoffFee;

  /// بيحول السلة لطلب شاشة الانتظار، والتوصيل = رسوم الاستلام + التسليم
  /// [orderId] هو رقم الطلب اللي رجع من التأكيد
  PendingOrderModel toPendingOrder({int orderId = 0}) {
    return PendingOrderModel(
      orderId: orderId,
      laundryName: laundryName,
      deliveryPrice: pickupFee + dropoffFee,
      lines: items
          .map(
            (item) => PendingOrderLine(
              itemId: item.laundryServiceItemId,
              name: item.name,
              quantity: item.quantity,
              price: item.unitPrice,
            ),
          )
          .toList(),
    );
  }
}
