import 'package:equatable/equatable.dart';

/// تسجيل الدخول بالرقم بس: بنبعت الكود وبعدين التحقق بيكمل في شاشة الـ OTP
class LoginEvent extends Equatable {
  /// الرقم كامل بكود الدولة (+218911234567)
  final String phoneNumber;

  const LoginEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
