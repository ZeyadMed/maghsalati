import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/register/data/register_data_source.dart';
import 'package:maghsalati/features/auth/register/models/register_model.dart';
import 'package:maghsalati/features/auth/register/presentation/logic/register_event.dart';

class RegisterBloc extends Bloc<RegisterEvent, BaseState<RegisterModel>> {
  final RegisterDataSource _registerDataSource;

  RegisterBloc(this._registerDataSource) : super(BaseState()) {
    on<RegisterEvent>(_onRegisterEvent);
  }

  Future<void> _onRegisterEvent(
    RegisterEvent event,
    Emitter<BaseState<RegisterModel>> emit,
  ) async {
    emit(BaseState(status: Status.loading));

    final result = await _registerDataSource.register(
      name: event.name,
      phoneNumber: event.phoneNumber,
      password: event.password,
      address: event.address,
      cityId: event.cityId,
      latitude: event.latitude,
      longitude: event.longitude,
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
