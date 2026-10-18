import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';

abstract interface class SavedAddressesDataSource {
  /// مترتبة من السيرفر: الافتراضي الأول وبعده الأحدث تعديلًا، فمابنعملش sort
  Future<Either<Failure, List<SavedAddressModel>>> getAddresses();

  /// بترجع العنوان اللي اتضاف عشان تأكيد الطلب يختاره على طول
  Future<Either<Failure, SavedAddressModel>> addAddress(
    SavedAddressRequest request,
  );

  Future<Either<Failure, void>> updateAddress(
    int addressId,
    SavedAddressRequest request,
  );

  Future<Either<Failure, void>> deleteAddress(int addressId);

  Future<Either<Failure, void>> setDefault(int addressId);
}

class SavedAddressesDataSourceImpl implements SavedAddressesDataSource {
  final GenericDataSource _genericDataSource;
  SavedAddressesDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, List<SavedAddressModel>>> getAddresses() {
    return _genericDataSource.fetchData<SavedAddressModel>(
      endpoint: Endpoints.savedAddresses,
      fromJson: SavedAddressModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, SavedAddressModel>> addAddress(
    SavedAddressRequest request,
  ) {
    // postData بتبعت الريسبونس كامل، والعنوان نفسه جوه data
    return _genericDataSource.postData<SavedAddressModel>(
      endpoint: Endpoints.savedAddresses,
      data: request.toJson(),
      fromJson: (json) =>
          SavedAddressModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, void>> updateAddress(
    int addressId,
    SavedAddressRequest request,
  ) async {
    final result = await _genericDataSource.updateData<Null>(
      endpoint: Endpoints.savedAddress(addressId),
      data: request.toJson(),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> deleteAddress(int addressId) async {
    final result = await _genericDataSource.deleteData<Null>(
      endpoint: Endpoints.savedAddress(addressId),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> setDefault(int addressId) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.defaultSavedAddress(addressId),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
