import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

/// الطلبات اللي لسه شغالة، لشريط متابعة الطلب اللي في الرئيسية.
/// الـ API مافيهوش فلتر بالحالة، فبنجيب أول صفحة ونفلتر منها، والطلبات الشغالة
/// هي الأحدث فغالبًا كلها فيها. الضيف مالوش طلبات فمابنجيبش حاجة
class ActiveOrdersCubit extends Cubit<List<OrderModel>> {
  final OrdersDataSource _dataSource;

  static const int _pageSize = 20;

  /// لو تحديثين اتبعتوا ورا بعض، نتيجة القديم بتتجاهل
  int _requestId = 0;

  ActiveOrdersCubit(this._dataSource) : super(const []);

  /// لو الطلب فشل بنسيب اللي معروض زي ما هو بدل ما الشريط يختفي ويرجع
  Future<void> load() async {
    final requestId = ++_requestId;
    if (await CacheManager.isGuestMode()) {
      if (!isClosed) emit(const []);
      return;
    }

    final result = await _dataSource.getOrders(
      pageIndex: 1,
      pageSize: _pageSize,
    );
    if (isClosed || requestId != _requestId) return;

    result.fold(
      (_) {},
      (page) => emit(page.orders.where((order) => order.isCurrent).toList()),
    );
  }

  /// طلب اتغير من الـ realtime: بيتبدل مكانه، أو بيتشال لو خلص،
  /// أو بيتضاف لو طلب شغال جديد
  void applyOrder(OrderModel order) {
    if (isClosed) return;
    final orders = state.where((item) => item.id != order.id).toList();
    if (order.isCurrent) {
      final index = state.indexWhere((item) => item.id == order.id);
      orders.insert(index < 0 ? 0 : index, order);
    }
    emit(orders);
  }
}
