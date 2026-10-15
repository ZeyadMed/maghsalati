import 'package:maghsalati/core/helpers/json_reader.dart';

/// القسم الفرعي اللي بيتعرض كشيب فوق القطع (قمصان - بناطيل - فساتين ...)
/// بيتفلتر بيه الجريد، وجاي من ال endpoint جوا القسم الرئيسي
class ServiceSubCategoryModel {
  final int id;
  final String name;

  const ServiceSubCategoryModel({required this.id, required this.name});

  /// أي exception هنا بيتبلع في fetchData والمنيو كلها بتطلع فاضية،
  /// فالـ id بيتقري بمرونة بدل cast
  factory ServiceSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceSubCategoryModel(
      id: asInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
