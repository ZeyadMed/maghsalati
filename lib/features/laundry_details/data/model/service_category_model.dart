import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_sub_category_model.dart';

/// فرع تحت القسم بيتعرض كشيب (قمصان - بناطيل)، و[items] هي اللي في الجريد
/// والـ name بيبقى null في فرع الأصناف العادية، والشاشة بتسميه "أخرى"
typedef ServiceBranch = ({String? name, List<ServiceItemModel> items});

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
          .map(
            (e) => ServiceSubCategoryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      items: ((json['items'] as List?) ?? [])
          .map((e) => ServiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// القطع اللي تبع قسم فرعي معين، و null معناها "الكل"
  /// والـ group بيبان لو هو أو أي نوع من أنواعه تبع القسم الفرعي
  List<ServiceItemModel> itemsOf(int? subCategoryId) {
    final visible = items.where((item) => item.isVisible);
    if (subCategoryId == null) return visible.toList();
    return visible
        .where(
          (item) =>
              item.subCategoryId == subCategoryId ||
              item.addableItems.any(
                (variant) => variant.subCategoryId == subCategoryId,
              ),
        )
        .toList();
  }

  /// الفروع اللي بتبان كشيبس تحت التاب: كل group فرع، وأنواعه المتسعّرة
  /// هي اللي بتتعرض في الجريد (قميص ← قميص كتان، قميص قطن)
  /// والأصناف العادية اللي مالهاش أنواع بتتجمع في فرع واحد في الآخر
  List<ServiceBranch> get branches {
    final branches = <ServiceBranch>[];
    final standalone = <ServiceItemModel>[];
    for (final item in items.where((item) => item.isVisible)) {
      if (item.isGroup) {
        branches.add((name: item.name, items: item.addableItems));
      } else {
        standalone.add(item);
      }
    }
    if (standalone.isNotEmpty) branches.add((name: null, items: standalone));
    return branches;
  }

  /// كل اللي يتضاف للسلة في القسم، والـ groups بتتفرد لأنواعها
  List<ServiceItemModel> get addableItems =>
      items.expand((item) => item.addableItems).toList();

  /// الـ ids اللي السلة بتتحسب بيها، زي البادج اللي على كارت القسم
  Iterable<int> get laundryServiceItemIds =>
      addableItems.map((item) => item.laundryServiceItemId).nonNulls;
}
