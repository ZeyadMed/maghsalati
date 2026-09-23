import 'package:dio/dio.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/helpers/logger.dart';
import 'package:maghsalati/core/http/endpoints.dart';

/// نتيجة محاولة التجديد. بنفرق بين إن الجلسة انتهت فعلاً وبين إن النت
/// وقع أو السيرفر عطلان، عشان مانطردش المستخدم على مشكلة مؤقتة.
sealed class RefreshResult {
  const RefreshResult();
}

class RefreshSuccess extends RefreshResult {
  final String accessToken;
  const RefreshSuccess(this.accessToken);
}

/// الباك رفض الـ refresh token (أو مفيش واحد أصلاً)، لازم يسجل دخول تاني
class RefreshSessionExpired extends RefreshResult {
  const RefreshSessionExpired();
}

/// فشل مؤقت (نت، timeout، 5xx)، التوكنز لسه صالحة ومش هنمسحها
class RefreshTransientFailure extends RefreshResult {
  final DioException cause;
  const RefreshTransientFailure(this.cause);
}

/// بيتولى تجديد الـ accessToken باستخدام الـ refreshToken.
///
/// بيستخدم Dio مستقل (من غير الانترسبتور) عشان لو التجديد نفسه رجع 401
/// مايدخلش في لوب لا نهائي بيحاول يجدد التجديد.
class TokenRefreshService {
  TokenRefreshService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Endpoints.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Accept-Encoding': 'identity',
                'Accept-Language': 'ar',
              },
            ),
          );

  final Dio _dio;

  /// الأكواد اللي معناها إن الـ refresh token نفسه مرفوض
  static const _rejectedStatusCodes = {400, 401, 403};

  /// لو فيه تجديد شغال بالفعل، أي ريكوست تاني بيستنى نفس النتيجة
  /// بدل ما نبعت كذا طلب تجديد في نفس الوقت ونحرق الـ refresh token.
  Future<RefreshResult>? _ongoingRefresh;

  bool get hasRefreshToken {
    final token = CacheManager.getRefreshTokenSync();
    return token != null && token.isNotEmpty;
  }

  /// المكالمات المتوازية بتشارك نفس العملية.
  Future<RefreshResult> refresh() {
    return _ongoingRefresh ??= _performRefresh().whenComplete(() {
      _ongoingRefresh = null;
    });
  }

  Future<RefreshResult> _performRefresh() async {
    final refreshToken = CacheManager.getRefreshTokenSync();
    if (refreshToken == null || refreshToken.isEmpty) {
      loggerWarn('Refresh skipped: no refresh token stored');
      return const RefreshSessionExpired();
    }

    try {
      final response = await _dio.post(
        Endpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
          'deviceInfo': '',
          'deviceId': '',
        },
      );

      final body = response.data;
      if (body is! Map) {
        loggerError('Refresh failed: unexpected response shape');
        return const RefreshSessionExpired();
      }

      // الباك بيرجع التوكنز جوه data مش في الروت
      final data = body['data'] is Map ? body['data'] as Map : body;

      final newAccessToken = data['accessToken']?.toString();
      final newRefreshToken = data['refreshToken']?.toString();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        loggerError('Refresh failed: response had no accessToken');
        return const RefreshSessionExpired();
      }

      // الباك اند بيدوّر الـ refresh token، فلو رجع واحد جديد لازم نحفظه
      // وإلا الطلب الجاي هيستخدم توكن محروق.
      await CacheManager.saveTokens(
        accessToken: newAccessToken,
        refreshToken: (newRefreshToken != null && newRefreshToken.isNotEmpty)
            ? newRefreshToken
            : refreshToken,
      );

      // الريسبونس بيرجع بيانات المستخدم كمان، فبنحدثها مع التوكنز
      final userName = data['userName']?.toString();
      if (userName != null) {
        await CacheManager.saveUserData(
          userId: data['userId']?.toString() ?? '',
          userName: userName,
          role: data['role']?.toString() ?? '',
          email: data['email']?.toString(),
        );
      }

      logger('Access token refreshed');
      return RefreshSuccess(newAccessToken);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      loggerError('Refresh request failed: $statusCode $e');
      if (_rejectedStatusCodes.contains(statusCode)) {
        return const RefreshSessionExpired();
      }
      return RefreshTransientFailure(e);
    } catch (e) {
      loggerError('Refresh request failed: $e');
      return const RefreshSessionExpired();
    }
  }
}
