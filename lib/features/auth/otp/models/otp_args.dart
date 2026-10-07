/// الـ purpose هو اللي بيحدد الكود بيتحقق منه إزاي وبعد النجاح بنروح فين.
/// نسيت كلمة المرور مابتعديش من هنا، الكود بتاعها بيتكتب في شاشة
/// تغيير كلمة المرور ويتبعت مع كلمة المرور الجديدة في reset-password
enum OtpPurpose {
  /// بعد إنشاء حساب: بنفعل الرقم ونوديه الناف بار
  register,
}

/// بيتبعت في state.extra لشاشة الـ OTP
class OtpArgs {
  final String phoneNumber;
  final OtpPurpose purpose;

  const OtpArgs({required this.phoneNumber, required this.purpose});
}
