import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/wallet/data/wallet_data_source.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/redeem_code_cubit.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_transactions_cubit.dart';

class WalletServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<WalletDataSource>(
      () => WalletDataSourceImpl(getIt()),
    );
    // singleton: الرصيد واحد لحسابي وشاشة المحفظة واختيار طريقة الدفع
    getIt.registerLazySingleton<WalletBalanceCubit>(
      () => WalletBalanceCubit(getIt()),
    );
    getIt.registerFactory<WalletTransactionsCubit>(
      () => WalletTransactionsCubit(getIt()),
    );
    getIt.registerFactory<RedeemCodeCubit>(
      () => RedeemCodeCubit(getIt(), getIt()),
    );
  }
}
