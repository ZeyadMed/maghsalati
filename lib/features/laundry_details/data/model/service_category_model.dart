import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';

/// القسم الرئيسي (ملابس - بدل - فساتين - مفروشات ...) وجواه القطع الفرعية
class ServiceCategoryModel {
  final int id;
  final String name;

  /// ممكن تكون لينك صورة من السيرفر أو إيموجي، والـ UI بيتعامل مع الاتنين
  final String image;
  final List<ServiceItemModel> items;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.items,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      items: ((json['items'] as List?) ?? [])
          .map((e) => ServiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
