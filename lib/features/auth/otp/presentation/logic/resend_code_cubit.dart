import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/login/data/login_data_source.dart';
import 'package:maghsalati/features/auth/otp/data/verify_phone_data_source.dart';
import 'package:maghsalati/features/auth/otp/models/otp_args.dart';

/// زرار إعادة الإرسال في شاشة الـ OTP، والـ data في النجاح هي رسالة الباك.
/// الكود بيتبعت تاني من نفس المكان اللي بعته أول مرة
class ResendCodeCubit extends Cubit<BaseState<String>> {
  final VerifyPhoneDataSource _verifyPhoneDataSource;
  final LoginDataSource _loginDataSource;

  ResendCodeCubit(this._verifyPhoneDataSource, this._loginDataSource)
    : super(const BaseState<String>());

  Future<void> resend(String phoneNumber, OtpPurpose purpose) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    final result = switch (purpose) {
      OtpPurpose.login => await _loginDataSource.sendLoginCode(
        phoneNumber: phoneNumber,
      ),
      OtpPurpose.register => await _verifyPhoneDataSource.resendCode(
        phoneNumber: phoneNumber,
      ),
    };
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (message) => emit(state.copyWith(status: Status.success, data: message)),
    );
  }
}
