import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';

abstract interface class ProfileDataSource {
  Future<Either<Failure, UserModel>> getProfile();

  /// بتبعت الاسم والعنوان والمدينة والإحداثيات بس، التليفون مابيتعدلش من هنا
  Future<Either<Failure, void>> updateProfile(UserModel user);
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
  Future<Either<Failure, void>> updateProfile(UserModel user) async {
    final result = await _genericDataSource.updateData<Null>(
      endpoint: Endpoints.customerProfile,
      data: user.toUpdateJson(),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
