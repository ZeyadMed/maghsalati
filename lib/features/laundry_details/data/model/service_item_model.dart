/// قطعة فرعية جوا القسم (قميص - بنطلون - تيشيرت ...)
/// جايه من ال endpoint فمفيش حاجة ثابتة هنا
class ServiceItemModel {
  final int id;
  final String name;
  final num price;

  /// وحدة التسعير زي "قطعة" - بتيجي من السيرفر عشان تتغير حسب الخدمة
  final String unit;

  /// صورة القطعة، ممكن تكون لينك من السيرفر أو إيموجي، والـ UI بيتعامل مع الاتنين
  final String image;

  /// الـ id بتاع القسم الفرعي اللي القطعة تبعه (قمصان - بناطيل ...)
  /// بتتفلتر بيه الشيبس فوق، ولو فاضي القطعة بتبان في "الكل" بس
  final int? subCategoryId;

  const ServiceItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.image = '',
    this.subCategoryId,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: json['price'] as num? ?? 0,
      unit: json['unit'] as String? ?? '',
      image: json['image'] as String? ?? '',
      subCategoryId: json['sub_category_id'] as int?,
    );
  }
}
