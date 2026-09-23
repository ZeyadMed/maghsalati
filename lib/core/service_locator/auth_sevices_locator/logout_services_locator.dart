import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/auth/logout/data/logout_data_source.dart';
import 'package:maghsalati/features/auth/logout/presentation/logic/logout_bloc.dart';

class LogoutServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<LogoutDataSource>(
      () => LogoutDataSourceImpl(getIt()),
    );
    getIt.registerFactory<LogoutBloc>(
      () => LogoutBloc(getIt()),
    );
  }
}
