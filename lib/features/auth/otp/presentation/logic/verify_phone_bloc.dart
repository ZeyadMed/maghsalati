import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/otp/data/verify_phone_data_source.dart';
import 'package:maghsalati/features/auth/models/auth_model.dart';
import 'package:maghsalati/features/auth/otp/presentation/logic/verify_phone_event.dart';

class VerifyPhoneBloc extends Bloc<VerifyPhoneEvent, BaseState<AuthModel>> {
  final VerifyPhoneDataSource _verifyPhoneDataSource;

  VerifyPhoneBloc(this._verifyPhoneDataSource) : super(BaseState()) {
    on<VerifyPhoneEvent>(_onVerifyPhoneEvent);
  }

  Future<void> _onVerifyPhoneEvent(
    VerifyPhoneEvent event,
    Emitter<BaseState<AuthModel>> emit,
  ) async {
    emit(BaseState(status: Status.loading));

    final result = await _verifyPhoneDataSource.verifyPhone(
      phoneNumber: event.phoneNumber,
      code: event.code,
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
