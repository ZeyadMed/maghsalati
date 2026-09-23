import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// مكان واحد لكل حاجة تخص جلسة المستخدم: مسح بياناته عند الخروج
/// أو انتهاء الجلسة، ومنع التحويل للوجين أكتر من مرة.
abstract final class Session {
  static bool _expiryHandled = false;

  /// بتمسح التوكنز وبيانات المستخدم والسلة، عشان اللي يدخل بعده
  /// مايلاقيش حاجة من الحساب القديم
  static Future<void> clear() async {
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

  /// بتتنادى بعد لوجين ناجح عشان لو الجلسة الجديدة انتهت نحوّل تاني
  static void started() => _expiryHandled = false;
}
