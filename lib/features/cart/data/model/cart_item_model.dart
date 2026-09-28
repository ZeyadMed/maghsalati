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

  const CartItemModel({
    required this.id,
    required this.laundryServiceItemId,
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
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
    );
  }
}
