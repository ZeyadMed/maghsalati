import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/realtime/realtime_service.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// مكان واحد لكل حاجة تخص جلسة المستخدم: مسح بياناته عند الخروج
/// أو انتهاء الجلسة، ومنع التحويل للوجين أكتر من مرة.
abstract final class Session {
  static bool _expiryHandled = false;

  /// بتمسح التوكنز وبيانات المستخدم والسلة، عشان اللي يدخل بعده
  /// مايلاقيش حاجة من الحساب القديم
  /// والـ realtime بيقفل عشان الحساب اللي بعده مايستقبلش أحداثه
  static Future<void> clear() async {
    if (getIt.isRegistered<RealtimeService>()) {
      await getIt<RealtimeService>().stop();
    }
    await CacheManager.clearTokens();
    await CacheManager.clearUserData();
    if (getIt.isRegistered<SelectedServicesController>()) {
      getIt<SelectedServicesController>().clear();
    }
  }

  /// لما كذا ريكوست يقعوا بـ 401 مع بعض، أول واحد بس هو اللي
  /// بيرجع true وبيحوّل المستخدم للوجين، والباقي بيتجاهلوا
  static bool claimExpiryRedirect() {
    if (_expiryHandled) return false;
    _expiryHandled = true;
    return true;
  }

  /// بتتنادى بعد لوجين ناجح عشان لو الجلسة الجديدة انتهت نحوّل تاني،
  /// وبتوصل الـ realtime على طول (لو كان ضيف والبوتوم ناف مفتوح أصلًا
  /// مش هيتبني تاني فمش هيوصل هو)
  static void started() {
    _expiryHandled = false;
    if (getIt.isRegistered<RealtimeService>()) {
      getIt<RealtimeService>().start();
    }
  }
}
