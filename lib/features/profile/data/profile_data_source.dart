import 'dart:io';

import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';

abstract interface class ProfileDataSource {
  Future<Either<Failure, UserModel>> getProfile();

  /// بتبعت الاسم والعنوان والمدينة والإحداثيات، والصورة لو اتغيرت بس
  /// التليفون مابيتعدلش من هنا. بترجع البروفايل زي ما اتحفظ في الباك
  Future<Either<Failure, UserModel>> updateProfile(
    UserModel user, {
    File? image,
  });

  Future<Either<Failure, void>> deleteAccount();
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final GenericDataSource _genericDataSource;
  ProfileDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, UserModel>> getProfile() {
    return _genericDataSource.fetchResult<UserModel>(
      endpoint: Endpoints.customerProfile,
      fromJson: UserModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile(
    UserModel user, {
    File? image,
  }) {
    // الاند بوينت بقت multipart/form-data، ولو Image مش مبعوتة
    // الباك بيسيب الصورة القديمة زي ما هي
    return _genericDataSource.putFormData<UserModel>(
      endpoint: Endpoints.customerProfile,
      data: {...user.toUpdateFields(), 'Image': ?image},
      // الرد هو نفس CustomerProfileDto بتاع الـ GET، وممكن ييجي جوه data
      fromJson: (json) => UserModel.fromJson(
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    final result = await _genericDataSource.deleteData<Null>(
      endpoint: Endpoints.customerAccount,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
