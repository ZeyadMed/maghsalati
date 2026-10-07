import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/change_password/presentation/logic/reset_password_event.dart';
import 'package:maghsalati/features/auth/forget_password/data/forget_password_data_source.dart';

/// الـ data في الـ state هي رسالة الباك بعد ما كلمة المرور تتغير
class ResetPasswordBloc extends Bloc<ResetPasswordEvent, BaseState<String>> {
  final ForgetPasswordDataSource _forgetPasswordDataSource;

  ResetPasswordBloc(this._forgetPasswordDataSource) : super(BaseState()) {
    on<ResetPasswordEvent>(_onResetPasswordEvent);
  }

  Future<void> _onResetPasswordEvent(
    ResetPasswordEvent event,
    Emitter<BaseState<String>> emit,
  ) async {
    emit(BaseState(status: Status.loading));

    final result = await _forgetPasswordDataSource.resetPassword(
      phoneNumber: event.phoneNumber,
      code: event.code,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(
        BaseState(status: Status.failure, errorMessage: failure.message),
      ),
      (message) => emit(BaseState(status: Status.success, data: message)),
    );
  }
}
