/// قطعة فرعية جوا القسم (قميص - بنطلون - تيشيرت ...)
/// جايه من ال endpoint فمفيش حاجة ثابتة هنا
class ServiceItemModel {
  /// ده الـ laundryServiceItemId، وهو اللي السلة بتتحسب بيه وبيتبعت مع الطلب
  final int id;
  final String name;
  final num price;

  /// وحدة التسعير زي "قطعة"، الـ endpoint لسه مابيرجعهاش فبتفضل فاضية
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
      id: (json['laundryServiceItemId'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price'] as num? ?? 0,
      unit: json['unit']?.toString() ?? '',
      image: json['imageUrl']?.toString() ?? '',
      subCategoryId: (json['subCategoryId'] as num?)?.toInt(),
    );
  }
}
