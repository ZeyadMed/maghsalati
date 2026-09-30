import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/helpers/json_reader.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

abstract interface class CartDataSource {
  Future<Either<Failure, CartModel>> getCart();

  Future<Either<Failure, void>> updateQuantity({
    required int cartItemId,
    required int quantity,
  });

  Future<Either<Failure, void>> removeItem(int cartItemId);

  Future<Either<Failure, void>> clearCart();

  /// بيرجع رقم الطلب اللي اتعمل، و 0 لو مقدرناش نعرفه
  Future<Either<Failure, int>> confirmCart(ConfirmCartRequest request);
}

class CartDataSourceImpl implements CartDataSource {
  final GenericDataSource _genericDataSource;
  CartDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, CartModel>> getCart() async {
    final result = await _genericDataSource.fetchResult<CartModel>(
      endpoint: Endpoints.cart,
      fromJson: (json) => CartModel.fromJson(json),
    );
    return result;
  }

  @override
  Future<Either<Failure, void>> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final result = await _genericDataSource.updateData<Null>(
      endpoint: Endpoints.cartItem(cartItemId),
      data: {'quantity': quantity},
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> removeItem(int cartItemId) async {
    final result = await _genericDataSource.deleteData<Null>(
      endpoint: Endpoints.cartItem(cartItemId),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    final result = await _genericDataSource.deleteData<Null>(
      endpoint: Endpoints.cart,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, int>> confirmCart(ConfirmCartRequest request) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.confirmCart,
      data: request.toJson(),
    );
    if (result.isError) return Left(result.throwError());

    final orderId = _orderIdOf(result.getOrThrow());
    if (orderId > 0) return Right(orderId);
    // الطلب اتعمل خلاص، فلو رقمه مش في الرد بنجيبه من الطلبات بدل ما نرجع خطأ
    return Right(await _latestNewOrderId());
  }

  /// شكل رد التأكيد مش متوثق: الرقم ممكن ييجي في data على طول،
  /// أو جوه data كـ orderId أو id، أو في الروت
  static int _orderIdOf(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is num) return data.toInt();
    if (data is Map<String, dynamic>) {
      return data.pickInt(['orderId', 'id'], inside: ['order']) ?? 0;
    }
    return response.pickInt(['orderId']) ?? 0;
  }

  /// أكبر رقم بين الطلبات الجديدة، لأن الطلب اللي لسه متأكد هو آخر واحد اتعمل
  /// ولو مفيش طلب جديد بنرجع 0 بدل ما نفتح طلب غلط
  Future<int> _latestNewOrderId() async {
    final result = await _genericDataSource.fetchResult<OrdersPageModel>(
      endpoint: Endpoints.orders,
      queryParameters: {'PageIndex': 1, 'PageSize': 10},
      fromJson: OrdersPageModel.fromJson,
    );
    return result.fold<int>(
      (_) => 0,
      (page) => page.orders
          .where((order) => order.status == OrderStatus.newOrder)
          .fold<int>(
            0,
            (latest, order) => order.id > latest ? order.id : latest,
          ),
    );
  }
}
