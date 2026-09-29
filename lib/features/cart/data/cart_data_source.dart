import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';

abstract interface class CartDataSource {
  Future<Either<Failure, CartModel>> getCart();

  Future<Either<Failure, void>> updateQuantity({
    required int cartItemId,
    required int quantity,
  });

  Future<Either<Failure, void>> removeItem(int cartItemId);

  Future<Either<Failure, void>> clearCart();

  Future<Either<Failure, void>> confirmCart(ConfirmCartRequest request);
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
  Future<Either<Failure, void>> confirmCart(ConfirmCartRequest request) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.confirmCart,
      data: request.toJson(),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
