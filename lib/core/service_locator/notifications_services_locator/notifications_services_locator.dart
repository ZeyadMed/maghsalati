import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/notifications/data/notifications_data_source.dart';
import 'package:maghsalati/features/notifications/presentation/view_model/notifications_cubit.dart';

class NotificationsServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<NotificationsDataSource>(
      () => NotificationsDataSourceImpl(getIt()),
    );
    getIt.registerFactory<NotificationsCubit>(
      () => NotificationsCubit(getIt()),
    );
  }
}
