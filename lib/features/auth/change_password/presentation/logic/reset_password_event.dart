import 'package:equatable/equatable.dart';

class ResetPasswordEvent extends Equatable {
  final String phoneNumber;

  /// الكود اللي وصل من forgot-password
  final String code;
  final String newPassword;

  const ResetPasswordEvent({
    required this.phoneNumber,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [phoneNumber, code, newPassword];
}
