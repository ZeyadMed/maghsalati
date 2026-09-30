import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

/// الطلب المفتوح في شاشة التفاصيل من api/customer/orders/{id}
/// state.data فيه آخر نسخة، والقديمة بتفضل ظاهرة لحد ما الجديدة توصل
class OrderDetailsCubit extends Cubit<BaseState<OrderModel>> {
  final OrdersDataSource _dataSource;

  int _orderId = 0;

  /// لو اتعمل تحديثين ورا بعض، نتيجة القديم بتتجاهل
  int _requestId = 0;

  OrderDetailsCubit(this._dataSource) : super(const BaseState<OrderModel>());

  /// [initial] هو الطلب اللي جاي من الليستة لو موجود
  Future<void> load(int orderId, {OrderModel? initial}) {
    _orderId = orderId;
    if (initial != null) emit(state.copyWith(data: initial));
    return refresh();
  }

  Future<void> refresh() async {
    if (_orderId <= 0) return;
    final requestId = ++_requestId;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getOrderDetails(_orderId);

    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (order) => emit(state.copyWith(status: Status.success, data: order)),
    );
  }
}
