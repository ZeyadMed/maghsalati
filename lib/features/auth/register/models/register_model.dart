class RegisterModel {
  final String phoneNumber;

  /// رسالة الباك اند اللي بتتعرض للمستخدم بعد نجاح التسجيل
  final String message;

  RegisterModel({required this.phoneNumber, this.message = ''});

  /// بتاخد الريسبونس كامل، الرسالة في الروت والرقم جوه data
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return RegisterModel(
      phoneNumber: data['phoneNumber']?.toString() ?? "",
      message: json['message']?.toString() ?? "",
    );
  }
}
