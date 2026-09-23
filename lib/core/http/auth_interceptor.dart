import 'package:dio/dio.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/helpers/logger.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/session.dart';
import 'package:maghsalati/core/http/token_refresh_service.dart';

/// بيحط الـ accessToken على كل ريكوست، ولما ييجي 401 بيجدده
/// بالـ refreshToken ويعيد الريكوست تاني من غير ما المستخدم يحس.
///
/// كده التوكن بيتقرا من الكاش وقت الطلب نفسه، مش وقت تسجيل الـ Dio،
/// فبعد اللوجين مش محتاجين نعمل reset للـ DI عشان الهيدر يتحدث.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio retryDio,
    required TokenRefreshService refreshService,
  }) : _retryDio = retryDio,
       _refreshService = refreshService;

  /// Dio من غير الانترسبتور ده. لو عدنا الطلب بنفس الـ Dio وفشل، الـ onError
  /// بتاعه هيقف في الطابور ورا الطلب اللي مستنيه، ويحصل deadlock.
  final Dio _retryDio;
  final TokenRefreshService _refreshService;

  static const _retriedFlag = 'auth_interceptor_retried';
  static const _skipAuthFlag = 'auth_interceptor_skip';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // الداتا سورسز بتبعت Authorization: null للاند بوينتس المفتوحة،
    // فلازم نحترمه ومانكتبش فوقه التوكن المحفوظ
    final optedOut =
        options.headers.containsKey('Authorization') &&
        options.headers['Authorization'] == null;

    // طلب التجديد نفسه بياخد التوكن في الـ body مش في الهيدر
    if (optedOut ||
        options.path.contains(Endpoints.refreshToken) ||
        Endpoints.isPublicAuth(options.path)) {
      options.headers.remove('Authorization');
      options.extra[_skipAuthFlag] = true;
      return handler.next(options);
    }

    final accessToken = await CacheManager.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    final isUnauthorized = err.response?.statusCode == 401;
    final skipsAuth = requestOptions.extra[_skipAuthFlag] == true;
    final alreadyRetried = requestOptions.extra[_retriedFlag] == true;

    // بنجدد مرة واحدة بس لكل ريكوست، ومابنجددش للاند بوينتس المفتوحة
    if (!isUnauthorized || skipsAuth || alreadyRetried) {
      return handler.next(err);
    }

    // الـ onError هنا بيشتغل واحد ورا التاني، فلو ريكوست قبلنا جدد التوكن
    // بنعيد بالجديد على طول بدل ما نبعت refresh تاني ونحرق التوكن اللي اتدوّر
    final currentToken = await CacheManager.getAccessToken();
    final sentHeader = requestOptions.headers['Authorization'];
    if (currentToken != null &&
        currentToken.isNotEmpty &&
        sentHeader != 'Bearer $currentToken') {
      return _retry(requestOptions, currentToken, handler);
    }

    if (!_refreshService.hasRefreshToken) {
      loggerWarn('Got 401 with no refresh token stored');
      await Session.clear();
      return handler.next(err);
    }

    switch (await _refreshService.refresh()) {
      case RefreshSuccess(:final accessToken):
        return _retry(requestOptions, accessToken, handler);
      case RefreshSessionExpired():
        loggerWarn('Refresh rejected, session expired');
        await Session.clear();
        return handler.next(err);
      case RefreshTransientFailure(:final cause):
        // مابنمسحش التوكنز، وبنرجع خطأ التجديد (نت/timeout/5xx) بدل الـ 401
        // عشان _handleDioError يعرض رسالة الاتصال ومايرميش المستخدم على اللوجين
        loggerWarn('Refresh failed temporarily, keeping session');
        return handler.next(
          DioException(
            requestOptions: requestOptions,
            response: cause.response,
            type: cause.type,
            error: cause.error,
            message: cause.message,
          ),
        );
    }
  }

  Future<void> _retry(
    RequestOptions requestOptions,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await _retryDio.fetch(
        requestOptions
          ..headers['Authorization'] = 'Bearer $accessToken'
          ..extra[_retriedFlag] = true,
      );
      handler.resolve(response);
    } on DioException catch (e) {
      // توكن لسه متجدد واترفض، يبقى الجلسة مش صالحة
      if (e.response?.statusCode == 401) {
        loggerWarn('Retried request still unauthorized, session expired');
        await Session.clear();
      }
      handler.next(e);
    }
  }
}
