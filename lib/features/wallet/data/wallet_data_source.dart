import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/helpers/json_reader.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/wallet/data/model/wallet_transaction_model.dart';

abstract interface class WalletDataSource {
  /// رصيد المحفظة الحالي
  Future<Either<Failure, num>> getBalance();

  Future<Either<Failure, WalletTransactionsPageModel>> getTransactions({
    required int pageIndex,
    required int pageSize,
  });

  /// بيشحن المحفظة بكود، والسيرفر بيرجع 400 برسالة عربي لو الكود غلط أو مستخدم
  Future<Either<Failure, RechargeResultModel>> redeemCode(String code);
}

class WalletDataSourceImpl implements WalletDataSource {
  final GenericDataSource _genericDataSource;
  WalletDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, num>> getBalance() async {
    final result = await _genericDataSource.fetchResult<num>(
      endpoint: Endpoints.wallet,
      fromJson: (json) {
        final balance = json.pickNum(['balance']);
        if (balance == null) {
          throw const FormatException('Wallet response has no balance');
        }
        return balance;
      },
    );
    return result;
  }

  @override
  Future<Either<Failure, WalletTransactionsPageModel>> getTransactions({
    required int pageIndex,
    required int pageSize,
  }) {
    return _genericDataSource.fetchResult<WalletTransactionsPageModel>(
      endpoint: Endpoints.walletTransactions,
      queryParameters: {'PageIndex': pageIndex, 'PageSize': pageSize},
      fromJson: WalletTransactionsPageModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, RechargeResultModel>> redeemCode(String code) {
    return _genericDataSource.postData<RechargeResultModel>(
      endpoint: Endpoints.redeemWalletCode,
      data: {'code': code},
      fromJson: RechargeResultModel.fromResponse,
    );
  }
}
