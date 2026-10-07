import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';

abstract interface class ForgetPasswordDataSource {
  /// بتبعت كود الاستعادة على الرقم وبترجع رسالة الباك
  Future<Either<Failure, String>> forgotPassword({required String phoneNumber});

  /// بتغير كلمة المرور بالكود اللي وصل وبترجع رسالة الباك
  Future<Either<Failure, String>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });
}

class ForgetPasswordDataSourceImpl implements ForgetPasswordDataSource {
  final GenericDataSource _genericDataSource;
  ForgetPasswordDataSourceImpl(this._genericDataSource);

  /// الباك مشترك بين التلت أبلكيشنز فلازم نقوله نوع الحساب،
  /// وده أبلكيشن العميل فثابتة على Customer
  static const String _accountType = 'Customer';

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String phoneNumber,
  }) async {
    final result = await _genericDataSource.postData<String>(
      endpoint: Endpoints.forgotPassword,
      data: {'phoneNumber': phoneNumber, 'accountType': _accountType},
      headers: {'Authorization': null},
      fromJson: _message,
    );
    return result;
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    final result = await _genericDataSource.postData<String>(
      endpoint: Endpoints.resetPassword,
      data: {
        'phoneNumber': phoneNumber,
        'accountType': _accountType,
        'code': code,
        'newPassword': newPassword,
      },
      headers: {'Authorization': null},
      fromJson: _message,
    );
    return result;
  }

  /// شكل الريسبونس مش متوثق في الـ Swagger، فبناخد الرسالة من الروت بس
  static String _message(Map<String, dynamic> json) =>
      json['message']?.toString() ?? '';
}
