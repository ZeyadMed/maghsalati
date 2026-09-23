import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/login/data/login_data_source.dart';
import 'package:maghsalati/features/auth/login/presentation/logic/login_event.dart';
import 'package:maghsalati/features/auth/models/auth_model.dart';

class LoginBloc extends Bloc<LoginEvent, BaseState<AuthModel>> {
  final LoginDataSource _loginDataSource;

  LoginBloc(this._loginDataSource) : super(BaseState()) {
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(
    LoginEvent event,
    Emitter<BaseState<AuthModel>> emit,
  ) async {
    emit(BaseState(status: Status.loading));

    final result = await _loginDataSource.login(
      phoneNumber: event.phoneNumber,
      password: event.password,
      rememberMe: event.rememberMe,
      deviceInfo: event.deviceInfo,
      deviceId: event.deviceId,
    );

    result.fold(
      (failure) => emit(
        BaseState(status: Status.failure, errorMessage: failure.message),
      ),
      (data) => emit(BaseState(status: Status.success, data: data)),
    );
  }
}
