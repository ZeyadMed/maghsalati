import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/auth/register/models/register_model.dart';

abstract interface class RegisterDataSource {
  Future<Either<Failure, RegisterModel>> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String address,
    required int cityId,
    required double latitude,
    required double longitude,
    required String deviceInfo,
    required String deviceId,
  });
}

class RegiterDataSourceImpl implements RegisterDataSource {
  final GenericDataSource _genericDataSource;
  RegiterDataSourceImpl(this._genericDataSource);
  @override
  Future<Either<Failure, RegisterModel>> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String address,
    required int cityId,
    required double latitude,
    required double longitude,
    required String deviceInfo,
    required String deviceId,
  }) async {
    final result = await _genericDataSource.postData<RegisterModel>(
      endpoint: Endpoints.register,
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
        'password': password,
        'address': address,
        'cityId': cityId,
        'latitude': latitude,
        'longitude': longitude,
        'deviceInfo': deviceInfo,
        'deviceId': deviceId,
      },

      headers: {'Authorization': null},
      fromJson: (json) => RegisterModel.fromJson(json),
    );
    return result;
  }
}
