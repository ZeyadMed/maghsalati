import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  final String phoneNumber;
  final String password;

  /// لما تبقى true الباك بيطول عمر الجلسة
  final bool rememberMe;
  final String deviceInfo;
  final String deviceId;

  const LoginEvent({
    required this.phoneNumber,
    required this.password,
    this.rememberMe = true,
    this.deviceInfo = '',
    this.deviceId = '',
  });

  @override
  List<Object?> get props => [
    phoneNumber,
    password,
    rememberMe,
    deviceInfo,
    deviceId,
  ];
}
