/// بيانات المستخدم اللي بتتعرض في شاشة حسابي وبتتعدل في شاشة تعديل الملف
/// مكتوبة بنفس شكل الـ json اللي هييجي من السيرفر عشان لما الـ API يتوصل
/// مايتغيرش أي حاجة في الـ widgets
class UserModel {
  final int id;
  final String name;
  final String phone;
  final String email;

  /// صورة البروفايل، لو فاضية بنعرض أول حرف من الاسم بدالها
  final String? image;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.image,
  });

  /// أول حرف من الاسم، بيتعرض جوا الدايرة لما مفيش صورة
  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '' : trimmed.substring(0, 1);
  }

  bool get hasImage => image != null && image!.isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'image': image,
  };

  /// بترجع نسخة معدلة، بنستخدمها لما المستخدم يحفظ تعديلات الملف الشخصي
  UserModel copyWith({String? name, String? phone, String? email}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      image: image,
    );
  }
}
