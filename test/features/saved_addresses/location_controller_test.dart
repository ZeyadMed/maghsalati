import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/helpers/location_service.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/data/saved_addresses_data_source.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/save_address_cubit.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// سيرفر وهمي بنفس قواعد الافتراضي: أول عنوان افتراضي، وافتراضي واحد بالكتير،
/// وحذف الافتراضي بيخلي أحدث عنوان متعدّل هو الافتراضي
class _FakeServer implements SavedAddressesDataSource {
  final List<SavedAddressModel> _addresses = [];
  int _nextId = 1;
  int _clock = 0;
  final Map<int, int> _updatedAt = {};

  void seed(String title, double lat, {bool isDefault = false}) {
    _insert(title, lat, isDefault: isDefault);
  }

  SavedAddressModel _insert(String title, double lat, {bool isDefault = false}) {
    final makeDefault = isDefault || _addresses.isEmpty;
    if (makeDefault) _clearDefault();
    final address = _model(_nextId++, title, lat, makeDefault);
    _addresses.add(address);
    _updatedAt[address.id] = ++_clock;
    return address;
  }

  SavedAddressModel _model(int id, String title, double lat, bool isDefault) {
    return SavedAddressModel(
      id: id,
      title: title,
      address: '$title street',
      latitude: lat,
      longitude: lat,
      additionalDetails: null,
      isDefault: isDefault,
    );
  }

  void _clearDefault() {
    for (var i = 0; i < _addresses.length; i++) {
      final a = _addresses[i];
      if (a.isDefault) _addresses[i] = _model(a.id, a.title, a.latitude, false);
    }
  }

  /// الافتراضي الأول وبعده الأحدث تعديلًا، زي ترتيب السيرفر
  List<SavedAddressModel> get _sorted => [..._addresses]
    ..sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return _updatedAt[b.id]!.compareTo(_updatedAt[a.id]!);
    });

  @override
  Future<Either<Failure, List<SavedAddressModel>>> getAddresses() async =>
      Right(_sorted);

  @override
  Future<Either<Failure, SavedAddressModel>> addAddress(
    SavedAddressRequest request,
  ) async => Right(
    _insert(request.title, request.latitude, isDefault: request.isDefault),
  );

  @override
  Future<Either<Failure, void>> updateAddress(
    int addressId,
    SavedAddressRequest request,
  ) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteAddress(int addressId) async {
    final removed = _addresses.firstWhere((a) => a.id == addressId);
    _addresses.remove(removed);
    if (removed.isDefault && _addresses.isNotEmpty) {
      final latest = _sorted.first;
      final index = _addresses.indexOf(latest);
      _addresses[index] = _model(latest.id, latest.title, latest.latitude, true);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setDefault(int addressId) async {
    final index = _addresses.indexWhere((a) => a.id == addressId);
    if (index == -1) {
      return Left(ServerFailure(message: 'العنوان غير موجود', statusCode: 404));
    }
    _clearDefault();
    final a = _addresses[index];
    _addresses[index] = _model(a.id, a.title, a.latitude, true);
    return const Right(null);
  }
}

/// GPS وهمي بيرجع نقطة ثابتة وبيعد كام مرة اتطلب
class _FakeLocationService implements LocationService {
  int calls = 0;

  @override
  Future<LocationResult> getCurrentAddress() async {
    calls++;
    return const LocationResult(
      status: LocationStatus.success,
      address: 'GPS',
      latitude: 1,
      longitude: 1,
    );
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

void main() {
  late _FakeServer server;
  late _FakeLocationService gps;
  late SavedAddressesCubit addresses;
  late LocationController controller;

  setUp(() async {
    // الكيوبت مابيجيبش العناوين من غير جلسة
    SharedPreferences.setMockInitialValues({'refreshToken': 'r'});
    await CacheManager.init();

    server = _FakeServer();
    gps = _FakeLocationService();
    addresses = SavedAddressesCubit(server);
    controller = LocationController(service: gps, savedAddresses: addresses);
  });

  tearDown(() async {
    controller.dispose();
    await addresses.close();
  });

  /// الـ stream بتاع الكيوبت بيوصل في microtask، فبنسيبه يخلص
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('العنوان الافتراضي بيتاخد من غير ما نسأل على الـ GPS', () async {
    server.seed('Home', 10);
    server.seed('Work', 20);

    await controller.load();

    expect(controller.savedAddress?.title, 'Home');
    expect(controller.latitude, 10);
    expect(controller.isLoading, isFalse);
    expect(gps.calls, 0);
  });

  test('من غير عناوين بيرجع للـ GPS', () async {
    await controller.load();

    expect(controller.savedAddress, isNull);
    expect(controller.address, 'GPS');
    expect(controller.latitude, 1);
    expect(gps.calls, 1);
  });

  test('تعيين افتراضي جديد بينقل المغاسل عليه', () async {
    server.seed('Home', 10);
    server.seed('Work', 20);
    await controller.load();

    final work = addresses.state.items.firstWhere((a) => a.title == 'Work');
    final error = await addresses.setDefault(work);
    await settle();

    expect(error, isNull);
    expect(controller.savedAddress?.title, 'Work');
    expect(controller.latitude, 20);
    // السيرفر بيرجع الافتراضي أول الليستة
    expect(addresses.state.items.first.title, 'Work');
  });

  test('موقعي الحالي بيفضل لحد ما الافتراضي يتغير', () async {
    server.seed('Home', 10);
    server.seed('Work', 20);
    await controller.load();

    await controller.useCurrentLocation();
    expect(controller.savedAddress, isNull);
    expect(controller.latitude, 1);

    // تحميل الليستة تاني بنفس الافتراضي مابيرجعش للعنوان المحفوظ
    await addresses.load();
    await settle();
    expect(controller.savedAddress, isNull);

    // بس تعيين افتراضي جديد معناه إنه عايز يشتغل عليه
    final work = addresses.state.items.firstWhere((a) => a.title == 'Work');
    await addresses.setDefault(work);
    await settle();
    expect(controller.savedAddress?.title, 'Work');
  });

  test('حذف الافتراضي بيمشي على اللي السيرفر اختاره', () async {
    server.seed('Home', 10);
    server.seed('Work', 20);
    await controller.load();

    final home = addresses.state.items.firstWhere((a) => a.title == 'Home');
    await addresses.delete(home);
    await settle();

    expect(controller.savedAddress?.title, 'Work');
    expect(controller.savedAddress?.isDefault, isTrue);
  });

  test('حذف آخر عنوان بيرجع للـ GPS', () async {
    server.seed('Home', 10);
    await controller.load();
    expect(gps.calls, 0);

    await addresses.delete(addresses.state.items.single);
    await settle();
    await settle();

    expect(controller.savedAddress, isNull);
    expect(gps.calls, 1);
    expect(controller.address, 'GPS');
  });

  test('الخروج بيمسح عناوين الحساب، واللي بعده بيجيب بتوعه', () async {
    server.seed('Home', 10);
    await controller.load();

    addresses.reset();
    controller.reset();
    expect(controller.savedAddress, isNull);
    expect(addresses.state.items, isEmpty);

    server.seed('Work', 20, isDefault: true);
    await controller.load();
    expect(controller.savedAddress?.title, 'Work');
  });

  test('أول عنوان بيتضاف بيرجع افتراضي حتى لو مابعتناش true', () async {
    await addresses.load();
    final saveCubit = SaveAddressCubit(server, addresses);

    await saveCubit.save(
      const SavedAddressRequest(
        title: 'Home',
        address: 'Nasr City',
        latitude: 30,
        longitude: 31,
      ),
    );
    await settle();

    expect(saveCubit.state.data?.isDefault, isTrue);
    expect(addresses.defaultAddress?.title, 'Home');
    expect(controller.savedAddress?.title, 'Home');
    await saveCubit.close();
  });

  test('404 في تعيين الافتراضي بيرجع الرسالة وبيحدث الليستة', () async {
    server.seed('Home', 10);
    await addresses.load();
    final ghost = SavedAddressModel.fromJson({
      'id': 99,
      'title': 'Old',
      'address': 'x',
      'latitude': 0,
      'longitude': 0,
      'isDefault': false,
    });

    final error = await addresses.setDefault(ghost);

    expect(error, 'العنوان غير موجود');
    expect(addresses.state.items.single.title, 'Home');
    expect(addresses.isAnyBusy, isFalse);
  });
}
