/// الراجع من أي عملية بتسجل دخول المستخدم: تفعيل رقم الهاتف أو تسجيل الدخول
/// الاتنين بيرجعوا نفس الشكل فبنستخدم نفس الموديل
///
/// التوكنز بتتحفظ في الكاش جوه GenericDataSource.authenticate،
/// وموجودة هنا كمان لو أي شاشة احتاجتها على طول
class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String? email;
  final String userName;
  final String role;

  /// وقت انتهاء الـ accessToken بتوقيت UTC، بيرجع null لو الباك مابعتوش
  final DateTime? expiresAtUtc;

  /// رسالة الباك اند اللي بتتعرض للمستخدم بعد نجاح العملية
  final String message;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.userName,
    required this.role,
    this.email,
    this.expiresAtUtc,
    this.message = '',
  });

  /// بتاخد الريسبونس كامل، الرسالة في الروت والباقي جوه data
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthModel(
      accessToken: data['accessToken']?.toString() ?? "",
      refreshToken: data['refreshToken']?.toString() ?? "",
      // الباك بيبعته string بس بنأمن نفسنا لو رجع رقم
      userId: data['userId']?.toString() ?? "",
      email: data['email']?.toString(),
      userName: data['userName']?.toString() ?? "",
      role: data['role']?.toString() ?? "",
      expiresAtUtc: DateTime.tryParse(data['expiresAtUtc']?.toString() ?? ""),
      message: json['message']?.toString() ?? "",
    );
  }

  /// بيفرق بين العميل وأي نوع مستخدم تاني لو اتضاف بعدين
  bool get isCustomer => role == 'Customer';
}
