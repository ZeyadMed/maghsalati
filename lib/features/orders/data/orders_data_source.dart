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

  /// الطلب بكل تفاصيله، ومنه بناخد الرحلات والتعديل وحالة الدفع
  Future<Either<Failure, OrderModel>> getOrderDetails(int orderId);

  /// موافقة أو رفض تعديل المغسلة
  Future<Either<Failure, void>> respondToAdjustment({
    required int orderId,
    required bool approve,
  });

  /// بيدفع المستحق على الطلب بالطريقة دي وبيرجع الطلب بعد الدفع:
  /// البوابة فيها paymentUrl يتفتح، والمحفظة بتتسوّى على طول
  Future<Either<Failure, OrderModel>> payOrder({
    required int orderId,
    required PaymentMethod method,
  });

  /// تقييم مندوب رحلة خلصت، والتعليق اختياري
  Future<Either<Failure, void>> addDriverReview({
    required int tripId,
    required int rating,
    String? comment,
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

  @override
  Future<Either<Failure, OrderModel>> getOrderDetails(int orderId) {
    return _genericDataSource.fetchResult<OrderModel>(
      endpoint: Endpoints.orderDetails(orderId),
      fromJson: OrderModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, void>> respondToAdjustment({
    required int orderId,
    required bool approve,
  }) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.respondToAdjustment(orderId),
      data: {'approve': approve},
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, OrderModel>> payOrder({
    required int orderId,
    required PaymentMethod method,
  }) {
    return _genericDataSource.postData<OrderModel>(
      endpoint: Endpoints.payOrder(orderId),
      data: {'paymentMethod': method.apiValue},
      fromJson: orderFromResponse,
    );
  }

  @override
  Future<Either<Failure, void>> addDriverReview({
    required int tripId,
    required int rating,
    String? comment,
  }) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.driverReviews,
      data: {'deliveryTripId': tripId, 'rating': rating, 'comment': ?comment},
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}

/// postData بترجع الريسبونس كله، والـ OrderDto جوه data (أو في الروت لو
/// السيرفر مابيلفهوش). من غير رقم طلب الرد مالوش لازمة فبنعتبره غلط
OrderModel orderFromResponse(Map<String, dynamic> response) {
  final data = response['data'];
  final order = OrderModel.fromJson(
    data is Map<String, dynamic> ? data : response,
  );
  if (order.id <= 0) throw const FormatException('Order response has no id');
  return order;
}
