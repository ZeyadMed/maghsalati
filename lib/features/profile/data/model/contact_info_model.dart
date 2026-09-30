/// بيانات التواصل جاية من api/auth/contacts
/// أي قيمة ممكن تيجي فاضية، والشاشة بتخفي السطر بتاعها
class ContactInfoModel {
  final String phoneNumber1;
  final String phoneNumber2;
  final String email;

  const ContactInfoModel({
    required this.phoneNumber1,
    required this.phoneNumber2,
    required this.email,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      phoneNumber1: json['phoneNumber1']?.toString().trim() ?? '',
      phoneNumber2: json['phoneNumber2']?.toString().trim() ?? '',
      email: json['email']?.toString().trim() ?? '',
    );
  }
}
