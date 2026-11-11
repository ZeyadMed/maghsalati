import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/wallet/data/wallet_data_source.dart';

/// رصيد محفظة العميل من api/customer/wallet. singleton في get_it عشان حسابي
/// وشاشة المحفظة واختيار طريقة الدفع يشوفوا نفس الرصيد، وأي شحن أو دفع
/// بيحدثه للكل. state.data هو الرصيد، والقديم بيفضل ظاهر لحد ما الجديد يوصل
class WalletBalanceCubit extends Cubit<BaseState<num>> {
  final WalletDataSource _dataSource;

  /// لو اتعمل تحميلين ورا بعض، نتيجة القديم بتتجاهل
  int _requestId = 0;

  WalletBalanceCubit(this._dataSource) : super(const BaseState<num>());

  num? get balance => state.data;

  Future<void> load() async {
    final requestId = ++_requestId;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getBalance();

    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (balance) => emit(state.copyWith(status: Status.success, data: balance)),
    );
  }

  /// الخروج من الحساب: اللي يدخل بعده مايشوفش رصيده
  void reset() {
    if (isClosed) return;
    ++_requestId;
    emit(const BaseState<num>());
  }

  /// الرصيد الجديد وصل في رد الشحن، فمن غير ريكوست تاني
  void setBalance(num balance) {
    if (isClosed) return;
    ++_requestId;
    emit(state.copyWith(status: Status.success, data: balance));
  }
}
