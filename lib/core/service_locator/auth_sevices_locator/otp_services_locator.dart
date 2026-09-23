import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/auth/otp/data/verify_phone_data_source.dart';
import 'package:maghsalati/features/auth/otp/presentation/logic/verify_phone_bloc.dart';

class OtpServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<VerifyPhoneDataSource>(
      () => VerifyPhoneDataSourceImpl(getIt()),
    );
    getIt.registerFactory<VerifyPhoneBloc>(
      () => VerifyPhoneBloc(getIt()),
    );
  }
}
