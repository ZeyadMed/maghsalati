import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

abstract interface class OrdersDataSource {
  Future<Either<Failure, OrdersPageModel>> getOrders({
    required int pageIndex,
    required int pageSize,
  });
}

class OrdersDataSourceImpl implements OrdersDataSource {
  final GenericDataSource _genericDataSource;
  OrdersDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, OrdersPageModel>> getOrders({
    required int pageIndex,
    required int pageSize,
  }) {
    // fetchResult بتبعت اللي جوه data للموديل، وفيه الطلبات وبيانات الصفحات
    return _genericDataSource.fetchResult<OrdersPageModel>(
      endpoint: Endpoints.orders,
      queryParameters: {'PageIndex': pageIndex, 'PageSize': pageSize},
      fromJson: OrdersPageModel.fromJson,
    );
  }
}
