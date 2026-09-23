import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';

abstract interface class LogoutDataSource {
  Future<Either<Failure, void>> logout({required String refreshToken});
}

class LogoutDataSourceImpl implements LogoutDataSource {
  final GenericDataSource _genericDataSource;
  LogoutDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, void>> logout({required String refreshToken}) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.logout,
      data: {'refreshToken': refreshToken},
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
