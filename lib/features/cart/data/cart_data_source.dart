import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

abstract interface class CartDataSource {
  /// [savedAddressId] بيخلي السيرفر يحسب رسوم التوصيل ونطاقه على العنوان ده،
  /// و null يعني العنوان الافتراضي
  Future<Either<Failure, CartModel>> getCart({int? savedAddressId});

  Future<Either<Failure, void>> updateQuantity({
    required int cartItemId,
    required int quantity,
  });

  Future<Either<Failure, void>> removeItem(int cartItemId);

  Future<Either<Failure, void>> clearCart();

  /// بيرجع الطلب اللي اتعمل (OrderDto): New ومدفوع لو من المحفظة،
  /// أو PendingPayment ومعاه paymentUrl لو بالبوابة
  Future<Either<Failure, OrderModel>> confirmCart(ConfirmCartRequest request);
}

class CartDataSourceImpl implements CartDataSource {
  final GenericDataSource _genericDataSource;
  CartDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, CartModel>> getCart({int? savedAddressId}) async {
    final result = await _genericDataSource.fetchResult<CartModel>(
      endpoint: Endpoints.cart,
      queryParameters: {'savedAddressId': ?savedAddressId},
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
  Future<Either<Failure, OrderModel>> confirmCart(ConfirmCartRequest request) {
    return _genericDataSource.postData<OrderModel>(
      endpoint: Endpoints.confirmCart,
      data: request.toJson(),
      fromJson: orderFromResponse,
    );
  }
}
