import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/auth/register/data/city_data_source.dart';
import 'package:maghsalati/features/auth/register/models/city_model.dart';

/// بتجيب المدن اللي بتتعرض في الدروب داون بتاعة التسجيل
class CityCubit extends Cubit<BaseState<CityModel>> {
  final CityDataSource _cityDataSource;

  CityCubit(this._cityDataSource) : super(const BaseState<CityModel>());

  Future<void> getCities({String? search}) async {
    emit(state.copyWith(status: Status.loading));

    final result = await _cityDataSource.getCities(search: search);

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (data) => emit(state.copyWith(status: Status.success, items: data)),
    );
  }
}
