import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/profile/data/app_info_data_source.dart';
import 'package:maghsalati/features/profile/data/profile_data_source.dart';
import 'package:maghsalati/features/profile/presentation/view_model/contact_us_cubit.dart';
import 'package:maghsalati/features/profile/presentation/view_model/privacy_policy_cubit.dart';
import 'package:maghsalati/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:maghsalati/features/profile/presentation/view_model/update_profile_cubit.dart';

class ProfileServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<ProfileDataSource>(
      () => ProfileDataSourceImpl(getIt()),
    );
    getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt()));
    getIt.registerFactory<UpdateProfileCubit>(
      () => UpdateProfileCubit(getIt()),
    );

    getIt.registerLazySingleton<AppInfoDataSource>(
      () => AppInfoDataSourceImpl(getIt()),
    );
    getIt.registerFactory<ContactUsCubit>(() => ContactUsCubit(getIt()));
    getIt.registerFactory<PrivacyPolicyCubit>(
      () => PrivacyPolicyCubit(getIt()),
    );
  }
}
