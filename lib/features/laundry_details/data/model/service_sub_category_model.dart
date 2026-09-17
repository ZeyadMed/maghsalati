/// القسم الفرعي اللي بيتعرض كشيب فوق القطع (قمصان - بناطيل - فساتين ...)
/// بيتفلتر بيه الجريد، وجاي من ال endpoint جوا القسم الرئيسي
class ServiceSubCategoryModel {
  final int id;
  final String name;

  const ServiceSubCategoryModel({required this.id, required this.name});

  factory ServiceSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceSubCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}
