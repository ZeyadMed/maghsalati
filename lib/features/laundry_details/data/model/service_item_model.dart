import 'package:maghsalati/core/helpers/json_reader.dart';

/// قطعة فرعية جوا القسم (قميص - بنطلون - تيشيرت ...)
/// جايه من ال endpoint فمفيش حاجة ثابتة هنا
///
/// القطعة يا إما صنف عادي متسعّر بيتضاف للسلة، يا إما group ليه أنواع
/// في [subItems] (قميص ← قميص كتان، قميص نص كم). الـ group مالوش
/// laundryServiceItemId ولا سعر، والأنواع بتوعه هي اللي بتتضاف للسلة
class ServiceItemModel {
  /// ده اللي السلة بتتحسب بيه وبيتبعت مع الطلب، و null في الـ group
  final int? laundryServiceItemId;

  /// الـ id بتاع القطعة نفسها في الكتالوج، موجود في الـ group والأنواع
  final int serviceItemId;
  final String name;

  /// null في الـ group، والسعر بيبقى على الأنواع
  final num? price;

  /// وحدة التسعير زي "قطعة"، الـ endpoint لسه مابيرجعهاش فبتفضل فاضية
  final String unit;

  /// صورة القطعة، ممكن تكون لينك من السيرفر أو إيموجي، والـ UI بيتعامل مع الاتنين
  final String image;

  /// الـ id بتاع القسم الفرعي اللي القطعة تبعه (قمصان - بناطيل ...)
  /// بتتفلتر بيه الشيبس فوق، ولو فاضي القطعة بتبان في "الكل" بس
  final int? subCategoryId;

  /// أنواع القطعة، ولو مش فاضية القطعة group ومابتتضافش للسلة
  /// السيرفر بيرجع بس الأنواع اللي المغسلة مسعّراها
  final List<ServiceItemModel> subItems;

  const ServiceItemModel({
    required this.laundryServiceItemId,
    required this.serviceItemId,
    required this.name,
    required this.price,
    required this.unit,
    this.image = '',
    this.subCategoryId,
    this.subItems = const [],
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      laundryServiceItemId: asInt(json['laundryServiceItemId']),
      serviceItemId: asInt(json['serviceItemId']) ?? 0,
      name: json['name']?.toString() ?? '',
      price: asNum(json['price']),
      unit: json['unit']?.toString() ?? '',
      image: json['imageUrl']?.toString() ?? '',
      subCategoryId: asInt(json['subCategoryId']),
      subItems: (json['subItems'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ServiceItemModel.fromJson)
          .toList(),
    );
  }

  bool get isGroup => subItems.isNotEmpty;

  /// الشرط الوحيد اللي بيسمح بإضافة القطعة للسلة
  bool get isAddable => !isGroup && laundryServiceItemId != null;

  /// القطع اللي تتضاف للسلة: القطعة نفسها لو عادية، أو أنواعها لو group
  List<ServiceItemModel> get addableItems {
    if (isAddable) return [this];
    return subItems.expand((item) => item.addableItems).toList();
  }

  /// الـ group اللي مالوش أنواع متسعّرة والقطعة اللي مالهاش id مابيتعرضوش
  bool get isVisible => addableItems.isNotEmpty;
}
