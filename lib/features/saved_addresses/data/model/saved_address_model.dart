import 'package:easy_localization/easy_localization.dart';

/// عنوان محفوظ جاي من api/saved-addresses
class SavedAddressModel {
  /// الأسامي الجاهزة اللي بتتبعت للسيرفر زي ما هي، وبتتترجم وقت العرض بس
  static const String homeTitle = 'Home';
  static const String workTitle = 'Work';

  final int id;

  /// Home أو Work أو أي نص كتبه العميل
  final String title;

  /// العنوان الكامل المكتوب، وده اللي بيروح deliveryAddress في تأكيد الطلب
  final String address;
  final double latitude;
  final double longitude;

  /// عمارة، دور، شقة، تعليمات للمندوب
  final String? additionalDetails;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavedAddressModel({
    required this.id,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.additionalDetails,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  bool get isHome => title.trim().toLowerCase() == homeTitle.toLowerCase();

  bool get isWork => title.trim().toLowerCase() == workTitle.toLowerCase();

  /// الاسم اللي بيتعرض: Home و Work بيتترجموا، وأي نص تاني بيتعرض زي ما هو
  String get displayTitle {
    if (isHome) return 'address_title_home'.tr();
    if (isWork) return 'address_title_work'.tr();
    return title;
  }

  bool get hasDetails => additionalDetails?.trim().isNotEmpty ?? false;

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      additionalDetails: json['additionalDetails']?.toString(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  /// بنقارن بكل الحقول اللي بتتعرض، عشان تعديل العنوان الافتراضي نفسه
  /// (اسمه أو مكانه) يوصل للهيدر والمغاسل القريبة كأنه عنوان جديد
  @override
  bool operator ==(Object other) =>
      other is SavedAddressModel &&
      other.id == id &&
      other.title == title &&
      other.address == address &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.additionalDetails == additionalDetails &&
      other.isDefault == isDefault;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    address,
    latitude,
    longitude,
    additionalDetails,
    isDefault,
  );
}

/// الـ body بتاع إضافة وتعديل العنوان (SavedAddressRequestDto)
/// الحدود هنا هي نفس حدود السيرفر، والفورم بيتحقق بيها قبل الإرسال
class SavedAddressRequest {
  static const int titleMaxLength = 50;
  static const int addressMaxLength = 500;
  static const int detailsMaxLength = 500;

  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String? additionalDetails;

  /// في التعديل false أو null مابيشيلوش الافتراضي، فبنبعت true بس لما يتطلب
  final bool isDefault;

  const SavedAddressRequest({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.additionalDetails,
    this.isDefault = false,
  });

  static bool isValidLatitude(double value) => value >= -90 && value <= 90;

  static bool isValidLongitude(double value) => value >= -180 && value <= 180;

  Map<String, dynamic> toJson() {
    final details = additionalDetails?.trim() ?? '';
    return {
      'title': title.trim(),
      'address': address.trim(),
      'latitude': latitude,
      'longitude': longitude,
      // التفاصيل اختيارية، فالفاضي بيتبعت null بدل نص فاضي
      'additionalDetails': details.isEmpty ? null : details,
      'isDefault': isDefault,
    };
  }
}
