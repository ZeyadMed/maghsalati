import 'package:equatable/equatable.dart';

class ForgotPasswordEvent extends Equatable {
  /// الرقم كامل بكود الدولة، وهو نفسه اللي بيتبعت بعد كده في reset-password
  final String phoneNumber;

  const ForgotPasswordEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
