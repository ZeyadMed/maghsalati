import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/wallet/data/model/wallet_transaction_model.dart';
import 'package:maghsalati/features/wallet/data/wallet_data_source.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';

/// شحن المحفظة بكود على api/customer/wallet/redeem. بتتعمل جديدة مع كل
/// شيت شحن، ولما تنجح بتحدث الرصيد المشترك بالرصيد اللي في الرد
class RedeemCodeCubit extends Cubit<BaseState<RechargeResultModel>> {
  final WalletDataSource _dataSource;
  final WalletBalanceCubit _balance;

  RedeemCodeCubit(this._dataSource, this._balance)
    : super(const BaseState<RechargeResultModel>());

  Future<void> redeem(String code) async {
    // ريكوست واحد في المرة عشان الدبل كليك مايبعتش الكود مرتين
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    // السيرفر بيعمل normalize للحروف، فبنشيل المسافات بس
    final result = await _dataSource.redeemCode(code.trim());

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (recharge) {
        _balance.setBalance(recharge.newBalance);
        emit(state.copyWith(status: Status.success, data: recharge));
      },
    );
  }
}
