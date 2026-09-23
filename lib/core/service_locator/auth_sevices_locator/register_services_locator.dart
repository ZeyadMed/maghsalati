import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/auth/register/data/city_data_source.dart';
import 'package:maghsalati/features/auth/register/data/register_data_source.dart';
import 'package:maghsalati/features/auth/register/presentation/logic/city_cubit.dart';
import 'package:maghsalati/features/auth/register/presentation/logic/register_bloc.dart';

class RegisterServicesLocator {
  static  Future<void > init({required GetIt getIt}) async {
    getIt.registerLazySingleton<RegisterDataSource>(
      () => RegiterDataSourceImpl(getIt()),
    );
    getIt.registerFactory<RegisterBloc>(
      () => RegisterBloc(getIt()),
    );

    getIt.registerLazySingleton<CityDataSource>(
      () => CityDataSourceImpl(getIt()),
    );
    getIt.registerFactory<CityCubit>(
      () => CityCubit(getIt()),
    );
  }
  }
