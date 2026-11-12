import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/cart/data/cart_data_source.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/cart/presentation/view_model/confirm_cart_cubit.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

class CartServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<CartDataSource>(
      () => CartDataSourceImpl(getIt()),
    );
    // singleton عشان الشيت وتاب السلة يشاركوا نفس السلة، والرسوم بتتحسب
    // على العنوان الافتراضي لو العميل مااختارش عنوان للطلب
    getIt.registerLazySingleton<CartCubit>(
      () => CartCubit(
        getIt(),
        defaultAddressId: () => getIt<SavedAddressesCubit>().defaultAddress?.id,
      ),
    );
    // جديدة مع كل شيت تأكيد عشان ستيت الطلب اللي فات مايفضلش
    getIt.registerFactory<ConfirmCartCubit>(() => ConfirmCartCubit(getIt()));
  }
}
