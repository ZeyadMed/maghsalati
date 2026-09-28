import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_sub_category_model.dart';

/// القسم الرئيسي (غسيل الملابس - بدل - فساتين ...) وجواه القطع الفرعية
/// راجع من api/customer/laundries/{laundryId}/services
class ServiceCategoryModel {
  final int id;
  final String name;

  /// ممكن تكون لينك صورة من السيرفر أو إيموجي، والـ UI بيتعامل مع الاتنين
  /// ولو راجعة null بتبقى نص فاضي والكارت بيعرض إيموجي افتراضي
  final String image;

  /// الأقسام الفرعية اللي بتبان كشيبس فوق القطع، ولو فاضية الشيبس مابتبانش
  /// الـ endpoint لسه مابيرجعهاش فبتفضل فاضية
  final List<ServiceSubCategoryModel> subCategories;
  final List<ServiceItemModel> items;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.items,
    this.subCategories = const [],
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['imageUrl']?.toString() ?? '',
      subCategories: ((json['subCategories'] as List?) ?? [])
          .map((e) => ServiceSubCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: ((json['items'] as List?) ?? [])
          .map((e) => ServiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// القطع اللي تبع قسم فرعي معين، و null معناها "الكل"
  List<ServiceItemModel> itemsOf(int? subCategoryId) {
    if (subCategoryId == null) return items;
    return items
        .where((item) => item.subCategoryId == subCategoryId)
        .toList();
  }
}
