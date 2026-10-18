import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/login/data/login_data_source.dart';
import 'package:maghsalati/features/auth/login/presentation/logic/login_event.dart';

/// بيبعت كود الدخول على الرقم، والـ data في النجاح هي رسالة الباك
class LoginBloc extends Bloc<LoginEvent, BaseState<String>> {
  final LoginDataSource _loginDataSource;

  LoginBloc(this._loginDataSource) : super(BaseState()) {
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(
    LoginEvent event,
    Emitter<BaseState<String>> emit,
  ) async {
    emit(BaseState(status: Status.loading));

    final result = await _loginDataSource.sendLoginCode(
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
