import 'dart:io';

import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/auth/register/models/register_model.dart';

abstract interface class RegisterDataSource {
  Future<Either<Failure, RegisterModel>> register({
    required String name,
    required String phoneNumber,
    required String address,
    required int cityId,
    required double latitude,
    required double longitude,
    File? image,
  });
}

class RegiterDataSourceImpl implements RegisterDataSource {
  final GenericDataSource _genericDataSource;
  RegiterDataSourceImpl(this._genericDataSource);
  @override
  Future<Either<Failure, RegisterModel>> register({
    required String name,
    required String phoneNumber,
    required String address,
    required int cityId,
    required double latitude,
    required double longitude,
    File? image,
  }) async {
    // الاند بوينت بقت multipart/form-data من غير باسورد، والصورة اختيارية
    final result = await _genericDataSource.postFormData<RegisterModel>(
      endpoint: Endpoints.register,
      data: {
        'Name': name,
        'PhoneNumber': phoneNumber,
        'Address': address,
        'CityId': cityId,
        'Latitude': latitude,
        'Longitude': longitude,
        'Image': ?image,
      },

      headers: {'Authorization': null},
      fromJson: (json) => RegisterModel.fromJson(json),
    );
    return result;
  }
}
