import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/auth/login/data/login_data_source.dart';
import 'package:maghsalati/features/auth/login/presentation/logic/login_bloc.dart';

class LoginServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<LoginDataSource>(
      () => LoginDataSourceImpl(getIt()),
    );
    getIt.registerFactory<LoginBloc>(
      () => LoginBloc(getIt()),
    );
  }
}
