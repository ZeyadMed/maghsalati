import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';

abstract interface class LoginDataSource {
  /// بتبعت الرقم لـ customer/login فالباك بيبعت كود الدخول عليه،
  /// وبترجع رسالة الباك. التوكنز بتيجي بعد كده من verify-phone
  Future<Either<Failure, String>> sendLoginCode({required String phoneNumber});
}

class LoginDataSourceImpl implements LoginDataSource {
  final GenericDataSource _genericDataSource;
  LoginDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, String>> sendLoginCode({
    required String phoneNumber,
  }) async {
    final result = await _genericDataSource.postData<String>(
      endpoint: Endpoints.login,
      data: {
        'phoneNumber': phoneNumber,
        // ثابتة true عشان الجلسة تفضل عايشة ومايطلبش كود كل شوية
        'rememberMe': true,
        // الـ FCM عشان إشعارات الطلبات (التعديل ووصول المندوب) توصل للجهاز ده
        'deviceToken': await CacheManager.deviceToken(),
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
