import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/home/data/nearby_laundries_data_source.dart';
import 'package:maghsalati/features/home/presentation/view_model/nearby_laundries_cubit.dart';

class HomeServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<NearbyLaundriesDataSource>(
      () => NearbyLaundriesDataSourceImpl(getIt()),
    );
    getIt.registerFactory<NearbyLaundriesCubit>(
      () => NearbyLaundriesCubit(getIt(), getIt()),
    );
  }
}
