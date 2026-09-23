/// المدينة اللي بتتعرض في الدروب داون بتاعة التسجيل
/// الـ id هو اللي بيتبعت للباك اند في cityId، والاسم للعرض بس
class CityModel {
  final int id;
  final String name;

  CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['id'] ?? 0, name: json['name'] ?? "");
  }

  @override
  bool operator ==(Object other) =>
      other is CityModel && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
