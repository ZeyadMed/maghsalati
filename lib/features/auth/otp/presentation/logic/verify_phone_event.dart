import 'package:equatable/equatable.dart';

class VerifyPhoneEvent extends Equatable {
  final String phoneNumber;
  final String code;
  final String deviceInfo;
  final String deviceId;

  const VerifyPhoneEvent({
    required this.phoneNumber,
    required this.code,
    this.deviceInfo = '',
    this.deviceId = '',
  });

  @override
  List<Object?> get props => [phoneNumber, code, deviceInfo, deviceId];
}
