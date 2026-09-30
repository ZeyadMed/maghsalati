/// بيانات العميل جاية من api/customer/profile
/// بتتعرض في شاشة حسابي، والاسم والمدينة والعنوان بيتعدلوا من شاشة تعديل الملف
class UserModel {
  final int id;
  final String name;
  final String phoneNumber;
  final String address;
  final int cityId;
  final String cityName;
  final double latitude;
  final double longitude;
  final bool phoneNumberConfirmed;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.cityId,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.phoneNumberConfirmed,
    required this.createdAt,
  });

  /// أول حرف من الاسم، بيتعرض جوا الدايرة مكان الصورة
  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '' : trimmed.substring(0, 1);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      cityId: (json['cityId'] as num?)?.toInt() ?? 0,
      cityName: json['cityName']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      phoneNumberConfirmed: json['phoneNumberConfirmed'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  /// الـ body اللي بيتبعت في PUT api/customer/profile
  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    'address': address,
    'cityId': cityId,
    'latitude': latitude,
    'longitude': longitude,
  };

  /// بترجع نسخة معدلة، بنستخدمها لما المستخدم يحفظ تعديلات الملف الشخصي
  UserModel copyWith({
    String? name,
    String? address,
    int? cityId,
    String? cityName,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumberConfirmed: phoneNumberConfirmed,
      createdAt: createdAt,
    );
  }
}
