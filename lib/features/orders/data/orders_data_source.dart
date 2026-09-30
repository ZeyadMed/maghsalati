import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/helpers/json_reader.dart';
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

  /// بيرجع لينك الدفع الجديد لو السيرفر بعته في الرد، و null لو مابعتهوش
  Future<Either<Failure, String?>> retryPayment(int orderId);

  /// الكود اللي المندوب إداه للعميل لما وصل بالهدوم
  Future<Either<Failure, void>> confirmDropoff({
    required int tripId,
    required String otpCode,
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
  Future<Either<Failure, String?>> retryPayment(int orderId) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.retryPayment(orderId),
    );
    return result.fold(
      (failure) => Left(failure),
      (response) => Right(_paymentUrlOf(response)),
    );
  }

  @override
  Future<Either<Failure, void>> confirmDropoff({
    required int tripId,
    required String otpCode,
  }) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.confirmDropoff(tripId),
      data: {'otpCode': otpCode},
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  /// postData بترجع الريسبونس كله، واللينك ممكن ييجي نص في data
  /// أو جوه data.paymentUrl أو في الروت، لأن شكل الرد مش متوثق
  static String? _paymentUrlOf(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is String && data.startsWith('http')) return data;
    final url = data is Map<String, dynamic>
        ? data.pickString(['paymentUrl', 'url', 'invoiceUrl'])
        : response.pickString(['paymentUrl']);
    return url.isEmpty ? null : url;
  }
}
