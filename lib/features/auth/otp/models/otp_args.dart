/// شاشة الـ OTP مشتركة بين فلوين، والـ purpose هو اللي بيحدد
/// الكود بيتحقق منه إزاي وبعد النجاح بنروح فين
enum OtpPurpose {
  /// بعد إنشاء حساب: بنفعل الرقم ونوديه الناف بار
  register,

  /// بعد نسيت كلمة المرور: بنوديه شاشة تغيير كلمة المرور
  forgetPassword,
}

/// بيتبعت في state.extra لشاشة الـ OTP
class OtpArgs {
  final String phoneNumber;
  final OtpPurpose purpose;

  const OtpArgs({required this.phoneNumber, required this.purpose});
}

/// بيتبعت في state.extra لشاشة تغيير كلمة المرور جاي من الـ OTP
/// عشان الرقم والكود يتبعتوا مع كلمة المرور الجديدة في reset-password
class ResetPasswordArgs {
  final String phoneNumber;
  final String code;

  const ResetPasswordArgs({required this.phoneNumber, required this.code});
}
