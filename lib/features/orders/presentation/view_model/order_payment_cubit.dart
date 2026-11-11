import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';

/// بتدفع المستحق على الطلب من api/customer/orders/{id}/pay (الدفع المبدئي
/// لطلب PendingPayment أو فرق المطابقة). state.data فيه الطلب بعد الدفع:
/// بالبوابة فيه paymentUrl يتفتح، وبالمحفظة بيبقى اتسوّى خلاص
/// بتتعمل جديدة مع كل شيت دفع وبتتقفل معاه
class OrderPaymentCubit extends Cubit<BaseState<OrderModel>> {
  final OrdersDataSource _dataSource;
  final WalletBalanceCubit _wallet;

  OrderPaymentCubit(this._dataSource, this._wallet)
    : super(const BaseState<OrderModel>());

  Future<void> pay(int orderId, PaymentMethod method) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.payOrder(orderId: orderId, method: method);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (order) {
        // الرصيد اتخصم، فبنجيبه تاني عشان أي شاشة بتعرضه تتحدث
        if (method == PaymentMethod.wallet) _wallet.load();
        emit(state.copyWith(status: Status.success, data: order));
      },
    );
  }
}
