import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/auth/change_password/presentation/logic/reset_password_bloc.dart';
import 'package:maghsalati/features/auth/forget_password/data/forget_password_data_source.dart';
import 'package:maghsalati/features/auth/forget_password/presentation/logic/forgot_password_bloc.dart';

class ForgetPasswordServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<ForgetPasswordDataSource>(
      () => ForgetPasswordDataSourceImpl(getIt()),
    );
    getIt.registerFactory<ForgotPasswordBloc>(
      () => ForgotPasswordBloc(getIt()),
    );
    getIt.registerFactory<ResetPasswordBloc>(() => ResetPasswordBloc(getIt()));
  }
}
