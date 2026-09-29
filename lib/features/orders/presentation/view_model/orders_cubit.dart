import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

/// بتجيب طلبات العميل من api/customer/orders صفحة صفحة
/// state.page هي الصفحة اللي عليها الدور، و hasReachedMax لما الصفحات تخلص
class OrdersCubit extends Cubit<BaseState<OrderModel>> {
  final OrdersDataSource _dataSource;

  static const int _pageSize = 10;

  /// لو اليوزر عمل refresh وفيه صفحة لسه بتحمل، نتيجتها القديمة بتتجاهل
  int _requestId = 0;

  OrdersCubit(this._dataSource) : super(const BaseState<OrderModel>());

  /// أول صفحة، بتتنادى أول ما الشاشة تفتح ومع السحب للتحديث
  Future<void> getOrders() async {
    final requestId = ++_requestId;
    // الطلبات القديمة بتفضل ظاهرة لحد ما الجديدة توصل
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getOrders(
      pageIndex: 1,
      pageSize: _pageSize,
    );

    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          status: Status.success,
          items: page.orders,
          page: 2,
          hasReachedMax: page.isLastPage,
        ),
      ),
    );
  }

  /// الصفحة اللي بعدها، بتتنادى لما اليوزر يوصل لآخر الليستة
  Future<void> loadMore() async {
    if (state.hasReachedMax || state.isLoading || state.isLoadingMore) return;

    final requestId = _requestId;
    emit(state.copyWith(status: Status.isLoadingMore));

    final result = await _dataSource.getOrders(
      pageIndex: state.page,
      pageSize: _pageSize,
    );

    if (isClosed || requestId != _requestId) return;

    result.fold(
      // الليستة بتفضل زي ما هي، ولما يعمل سكرول تاني بيحاول تاني
      (failure) => emit(
        state.copyWith(
          status: Status.isLoadingMoreFauilare,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: Status.success,
          items: [...state.items, ...page.orders],
          page: state.page + 1,
          hasReachedMax: page.isLastPage,
        ),
      ),
    );
  }
}
