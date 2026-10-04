import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_reviews_data_source.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_services_data_source.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/laundry_reviews_cubit.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/add_to_cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/laundry_services_cubit.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/working_hours_cubit.dart';

class LaundryDetailsServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<LaundryServicesDataSource>(
      () => LaundryServicesDataSourceImpl(getIt()),
    );
    getIt.registerFactory<LaundryServicesCubit>(
      () => LaundryServicesCubit(getIt()),
    );
    getIt.registerFactory<WorkingHoursCubit>(
      () => WorkingHoursCubit(getIt()),
    );
    getIt.registerFactory<AddToCartCubit>(
      () => AddToCartCubit(getIt(), getIt(), getIt()),
    );
    getIt.registerLazySingleton<LaundryReviewsDataSource>(
      () => LaundryReviewsDataSourceImpl(getIt()),
    );
    getIt.registerFactory<LaundryReviewsCubit>(
      () => LaundryReviewsCubit(getIt()),
    );
  }
}
