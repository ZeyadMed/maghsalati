import 'package:flutter/foundation.dart';
import 'package:maghsalati/core/helpers/location_service.dart';

/// بيمسك حالة الموقع: بيحمّل ولا جاب عنوان ولا اليوزر رافض
/// متسجل كـ singleton في get_it فالعنوان بيتحفظ ويتشارك بين كل الشاشات
/// يعني الهوم تجيبه مرة واحدة وشاشة تأكيد الطلب تقراه جاهز
class LocationController extends ChangeNotifier {
  final LocationService _service;

  LocationController({LocationService? service})
    : _service = service ?? LocationService();

  bool _isLoading = false;
  LocationResult _result = const LocationResult(status: LocationStatus.denied);

  /// بيبقى true بعد أول محاولة، عشان مانعيدش الجلب كل ما الهوم تتبني
  bool _hasLoadedOnce = false;

  bool get isLoading => _isLoading;

  /// العنوان اللي بيتعرض، فاضي لو لسه ماتجابش
  String get address => _result.address;

  bool get hasAddress => _result.isSuccess && _result.address.isNotEmpty;

  /// الإحداثيات، أي شاشة تانية تقدر تبعتها مع الطلب لل endpoint
  double? get latitude => _result.latitude;

  double? get longitude => _result.longitude;

  /// لازم يروح للإعدادات لأن الرفض كان نهائي
  bool get needsSettings => _result.needsSettings;

  /// الـ GPS نفسه مقفول من الجهاز
  bool get isServiceDisabled =>
      _result.status == LocationStatus.serviceDisabled;

  /// بتتنادى أول ما الهوم تفتح. بتشتغل مرة واحدة بس عشان هي singleton
  /// ولو عايز تجيب تاني بالعافية استخدم [refresh]
  Future<void> load() async {
    if (_hasLoadedOnce || _isLoading) return;
    await refresh();
  }

  /// بتجيب الموقع من الأول مهما كانت الحالة
  Future<void> refresh() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _result = await _service.getCurrentAddress();
    } catch (_) {
      // مفروض الservice مابيرميش، بس ده ضمان أخير إن اللودينج يقف
      _result = const LocationResult(status: LocationStatus.failed);
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// الدوس على الموقع: لو رافض نهائي بيفتح الإعدادات، ولو الـ GPS مقفول
  /// بيفتح إعدادات الموقع، وغير كده بيحاول تاني عادي
  Future<void> retry() async {
    if (needsSettings) {
      await _service.openSettings();
      return;
    }
    if (isServiceDisabled) {
      await _service.openLocationSettings();
      return;
    }
    await refresh();
  }
}
