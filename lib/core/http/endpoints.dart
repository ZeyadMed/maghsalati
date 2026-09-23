abstract interface class Endpoints {
  static const String baseUrl = 'https://lavanderia.runasp.net/';
  static const String updateLocation = '';

  // ****************************** Auth ********************************
  static const String register = 'api/auth/customer/register';

  /// بتاخد { phoneNumber, code, deviceInfo, deviceId } وبترجع التوكنز
  static const String verifyPhone = 'api/auth/customer/verify-phone';

  /// المدن اللي بتتعرض في الدروب داون بتاعة التسجيل،
  /// بترجع list فيها { id, name } والـ id هو اللي بيتبعت في cityId
  static const String cities = 'api/auth/cities';
  static const String verifyOtp = 'verify-otp';
  static const String login = 'api/auth/customer/login';
  static const String forgetPassword = 'forgot/password';
  static const String resetPasssword = 'forgot/reset-password';
  static const String confirmPassword = '';
  static const String resentOtp = 'resend-otp';
  static const String forgetResendOtp = 'forgot/resend-otp';
  static const String forgetVerifyOtp = 'forgot/verify-otp';
  static const String logOut = 'logout';

  /// بناخد منها accessToken جديد لما القديم يقع بـ 401.
  /// بتستقبل { refreshToken, deviceInfo, deviceId } وبترجع الاتنين جداد جوه data.
  static const String refreshToken = 'api/auth/refresh-token';

  /// بتاخد { refreshToken } وبتلغي الجلسة من عند الباك
  static const String logout = 'api/auth/logout';
}
