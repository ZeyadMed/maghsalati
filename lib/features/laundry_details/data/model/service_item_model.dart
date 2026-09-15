/// قطعة فرعية جوا القسم (قميص - بنطلون - تيشيرت ...)
/// جايه من ال endpoint فمفيش حاجة ثابتة هنا
class ServiceItemModel {
  final int id;
  final String name;
  final num price;

  /// وحدة التسعير زي "قطعة" - بتيجي من السيرفر عشان تتغير حسب الخدمة
  final String unit;

  const ServiceItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: json['price'] as num? ?? 0,
      unit: json['unit'] as String? ?? '',
    );
  }
}
