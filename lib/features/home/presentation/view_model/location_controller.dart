import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/helpers/location_service.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

/// بيمسك الموقع اللي التطبيق شغال عليه: العنوان الافتراضي المحفوظ لو موجود،
/// ولو مفيش بيجيب موقع الـ GPS (بيحمّل ولا جاب عنوان ولا اليوزر رافض)
/// متسجل كـ singleton في get_it فالعنوان بيتحفظ ويتشارك بين كل الشاشات
/// والمغاسل القريبة بتتجاب بإحداثياته
class LocationController extends ChangeNotifier {
  final LocationService _service;
  final SavedAddressesCubit _savedAddresses;
  late final StreamSubscription<BaseState<SavedAddressModel>>
  _savedAddressesSubscription;

  LocationController({LocationService? service, required this._savedAddresses})
    : _service = service ?? LocationService() {
    // أي تغيير في العناوين (إضافة، حذف، تعيين افتراضي) بيوصل هنا
    // فالهيدر والمغاسل بيمشوا على الافتراضي الجديد لوحدهم
    _savedAddressesSubscription = _savedAddresses.stream.listen(
      _onSavedAddressesChanged,
    );
  }

  bool _isLoading = false;
  LocationResult _result = const LocationResult(status: LocationStatus.denied);

  /// بيبقى true بعد أول محاولة، عشان مانعيدش الجلب كل ما الهوم تتبني
  bool _hasLoadedOnce = false;

  /// العنوان المحفوظ اللي شغالين عليه، ولو موجود بيغطي على الـ GPS
  SavedAddressModel? _savedAddress;

  /// اليوزر اختار "موقعي الحالي" من الهيدر، فالافتراضي مابيغطيش على الـ GPS
  /// لحد ما يختار عنوان محفوظ تاني أو الافتراضي يتغير
  bool _prefersCurrentLocation = false;

  /// id الافتراضي في آخر ليستة وصلت، عشان نعرف إن الافتراضي اتغير فعلًا
  int? _lastDefaultId;

  /// العنوان المحفوظ اللي شغالين عليه، و null لو شغالين بالـ GPS
  SavedAddressModel? get savedAddress => _savedAddress;

  /// العنوان المحفوظ مش محتاج يستنى الـ GPS
  bool get isLoading => _savedAddress == null && _isLoading;

  /// العنوان اللي بيتعرض، فاضي لو لسه ماتجابش
  String get address => _savedAddress?.address ?? _result.address;

  bool get hasAddress => _savedAddress != null || hasCurrentLocation;

  /// عنوان الـ GPS اتجاب، حتى لو العنوان المحفوظ هو اللي بيتعرض دلوقتي
  bool get hasCurrentLocation =>
      _result.isSuccess && _result.address.isNotEmpty;

  /// عنوان الـ GPS لوحده، بيتعرض تحت "موقعي الحالي" في شيت العناوين
  String get currentLocationAddress => _result.address;

  /// الإحداثيات اللي المغاسل القريبة بتتجاب بيها
  double? get latitude => _savedAddress?.latitude ?? _result.latitude;

  double? get longitude => _savedAddress?.longitude ?? _result.longitude;

  /// لازم يروح للإعدادات لأن الرفض كان نهائي
  bool get needsSettings => _result.needsSettings;

  /// الـ GPS نفسه مقفول من الجهاز
  bool get isServiceDisabled =>
      _result.status == LocationStatus.serviceDisabled;

  /// بتتنادى أول ما الهوم تفتح. بتشتغل مرة واحدة بس عشان هي singleton
  /// العنوان الافتراضي أولى من الـ GPS، فبنستنى العناوين الأول عشان مانسألش
  /// على الصلاحية ولا نجيب المغاسل مرتين (مرة بالـ GPS ومرة بالافتراضي)
  Future<void> load() async {
    if (_hasLoadedOnce || _isLoading) return;

    _hasLoadedOnce = true;
    _isLoading = true;
    notifyListeners();

    await _savedAddresses.load();
    _isLoading = false;
    // الـ stream بتاع الكيوبت بيوصل في microtask بعدين، فبنقرا الليستة بنفسنا
    // عشان مانجيبش الـ GPS على الفاضي، ولما الـ stream يوصل مش هيلاقي جديد
    _onSavedAddressesChanged(_savedAddresses.state);

    if (_savedAddress != null) {
      notifyListeners();
      return;
    }
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

  /// اليوزر اختار عنوان محفوظ من الهيدر: بيتعرض والمغاسل بتتجاب بيه على طول،
  /// وتعيينه كافتراضي على السيرفر بيحصل بعدها
  void useSavedAddress(SavedAddressModel address) {
    _prefersCurrentLocation = false;
    if (_savedAddress == address) return;
    _savedAddress = address;
    notifyListeners();
  }

  /// اليوزر اختار "موقعي الحالي": بنجيب الـ GPS من جديد عشان ممكن يكون اتحرك
  Future<void> useCurrentLocation() async {
    _prefersCurrentLocation = true;
    _savedAddress = null;
    notifyListeners();
    await retry();
  }

  void _onSavedAddressesChanged(BaseState<SavedAddressModel> state) {
    if (!state.isSuccess) return;

    final defaultAddress = _savedAddresses.defaultAddress;
    // الافتراضي اتغير (اتعين عنوان تاني أو اتضاف عنوان افتراضي)، يبقى اليوزر
    // عايز المغاسل تتجاب بيه حتى لو كان مختار "موقعي الحالي" قبل كده
    final defaultChanged =
        defaultAddress != null && defaultAddress.id != _lastDefaultId;
    _lastDefaultId = defaultAddress?.id;
    if (_prefersCurrentLocation && !defaultChanged) return;
    _prefersCurrentLocation = false;

    if (defaultAddress == _savedAddress) return;

    _savedAddress = defaultAddress;
    notifyListeners();

    // اتمسحت كل العناوين فبنرجع للـ GPS، ولو ماكانش اتجاب قبل كده بنجيبه
    // (وده مش وقت load لأنها هي اللي بتجيب الـ GPS بعد الليستة)
    if (defaultAddress == null && !_isLoading && !hasCurrentLocation) {
      refresh();
    }
  }

  /// بتتنادى مع الخروج: الحساب اللي بعده يبدأ من الأول ويجيب عناوينه هو
  void reset() {
    _savedAddress = null;
    _prefersCurrentLocation = false;
    _lastDefaultId = null;
    _hasLoadedOnce = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _savedAddressesSubscription.cancel();
    super.dispose();
  }
}
