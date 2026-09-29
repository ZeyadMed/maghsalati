import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';
import 'package:maghsalati/features/orders/presentation/view_model/orders_cubit.dart';

class OrdersServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<OrdersDataSource>(
      () => OrdersDataSourceImpl(getIt()),
    );
    getIt.registerFactory<OrdersCubit>(() => OrdersCubit(getIt()));
  }
}
