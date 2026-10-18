import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/saved_addresses/data/saved_addresses_data_source.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/save_address_cubit.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

class SavedAddressesServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<SavedAddressesDataSource>(
      () => SavedAddressesDataSourceImpl(getIt()),
    );
    // singleton عشان شاشة عناويني وشيت الهيدر وتأكيد الطلب يشاركوا نفس الليستة
    // و LocationController بيسمع عليها عشان يمشي على العنوان الافتراضي
    getIt.registerLazySingleton<SavedAddressesCubit>(
      () => SavedAddressesCubit(getIt()),
    );
    // جديدة مع كل فورم إضافة أو تعديل
    getIt.registerFactory<SaveAddressCubit>(
      () => SaveAddressCubit(getIt(), getIt()),
    );
  }
}
