/// سياسة الخصوصية جاية من api/auth/privacy-policy
/// الـ content بيبقى HTML متكتب من لوحة التحكم
class PrivacyPolicyModel {
  final String content;

  /// null لو السيرفر مابعتش تاريخ أو بعته بشكل غلط
  final DateTime? updatedAt;

  const PrivacyPolicyModel({required this.content, required this.updatedAt});

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      content: json['content']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
