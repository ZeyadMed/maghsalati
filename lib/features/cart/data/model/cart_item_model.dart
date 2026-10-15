import 'package:maghsalati/core/helpers/json_reader.dart';

/// سطر في سلة العميل جاي من api/customer/cart
class CartItemModel {
  /// الـ id بتاع السطر نفسه في السلة
  final int id;

  /// الـ id بتاع القطعة في المغسلة، نفس اللي بيتبعت في الإضافة للسلة
  final int laundryServiceItemId;
  final String name;

  /// صورة القطعة، ولو مش موجودة بناخد صورة الخدمة، ولو الاتنين فاضيين
  /// الـ UI بيعرض إيموجي
  final String image;
  final num unitPrice;
  final int quantity;
  final num lineTotal;

  /// الصنف الأب لو القطعة نوع منه (قميص ← قميص كتان)، و null لو صنف عادي
  final int? parentItemId;

  /// اسم الصنف الأب بيتعرض سطر صغير تحت [name]، وفاضي لو صنف عادي
  final String parentItemName;

  const CartItemModel({
    required this.id,
    required this.laundryServiceItemId,
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.parentItemId,
    this.parentItemName = '',
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      laundryServiceItemId:
          (json['laundryServiceItemId'] as num?)?.toInt() ?? 0,
      name: json['serviceItemName']?.toString() ?? '',
      image:
          json['serviceItemImageUrl']?.toString() ??
          json['serviceImageUrl']?.toString() ??
          '',
      unitPrice: json['unitPrice'] as num? ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      lineTotal: json['lineTotal'] as num? ?? 0,
      parentItemId: asInt(json['parentItemId']),
      parentItemName: json['parentItemName']?.toString() ?? '',
    );
  }
}
