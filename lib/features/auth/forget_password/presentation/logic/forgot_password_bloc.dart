import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/forget_password/data/forget_password_data_source.dart';
import 'package:maghsalati/features/auth/forget_password/presentation/logic/forgot_password_event.dart';

/// الـ data في الـ state هي رسالة الباك بعد ما الكود يتبعت
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, BaseState<String>> {
  final ForgetPasswordDataSource _forgetPasswordDataSource;

  ForgotPasswordBloc(this._forgetPasswordDataSource) : super(BaseState()) {
    on<ForgotPasswordEvent>(_onForgotPasswordEvent);
  }

  Future<void> _onForgotPasswordEvent(
    ForgotPasswordEvent event,
    Emitter<BaseState<String>> emit,
  ) async {
    emit(BaseState(status: Status.loading));

    final result = await _forgetPasswordDataSource.forgotPassword(
      phoneNumber: event.phoneNumber,
    );

    result.fold(
      (failure) => emit(
        BaseState(status: Status.failure, errorMessage: failure.message),
      ),
      (message) => emit(BaseState(status: Status.success, data: message)),
    );
  }
}
