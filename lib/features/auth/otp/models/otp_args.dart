/// الـ purpose بيوضح الكود اتبعت ليه، والتحقق في الحالتين بيبقى من
/// verify-phone وبعد النجاح بنروح الناف بار.
/// نسيت كلمة المرور مابتعديش من هنا، الكود بتاعها بيتكتب في شاشة
/// تغيير كلمة المرور ويتبعت مع كلمة المرور الجديدة في reset-password
enum OtpPurpose {
  /// بعد إنشاء حساب: بنفعل الرقم ونوديه الناف بار
  register,

  /// من شاشة تسجيل الدخول: الكود اتبعت من customer/login
  login,
}

/// بيتبعت في state.extra لشاشة الـ OTP
class OtpArgs {
  final String phoneNumber;
  final OtpPurpose purpose;

  const OtpArgs({required this.phoneNumber, required this.purpose});
}
