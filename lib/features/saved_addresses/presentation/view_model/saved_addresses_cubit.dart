import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/data/saved_addresses_data_source.dart';

/// عناوين العميل المحفوظة من api/saved-addresses
/// singleton في get_it عشان شاشة عناويني وشيت الهيدر وتأكيد الطلب يقروا نفس الليستة،
/// و LocationController بيسمع عليها عشان المغاسل القريبة تمشي على العنوان الافتراضي.
/// بعد أي عملية بنجيب الليستة من السيرفر تاني، لأن الافتراضي ممكن يتغير
/// في أكتر من عنوان مع بعض (زي حذف الافتراضي)
class SavedAddressesCubit extends Cubit<BaseState<SavedAddressModel>> {
  final SavedAddressesDataSource _dataSource;

  /// مفتاح في الـ metadata بيشيل id العنوان اللي بيتحذف أو بيتعمل افتراضي دلوقتي
  static const String _busyKey = 'busyAddressId';

  /// لو كذا تحميل راحوا ورا بعض بناخد نتيجة آخر واحد بس
  int _requestId = 0;

  SavedAddressesCubit(this._dataSource)
    : super(const BaseState<SavedAddressModel>());

  /// السيرفر بيرجع افتراضي واحد بالكتير، وبيبقى أول الليستة
  SavedAddressModel? get defaultAddress =>
      state.items.where((address) => address.isDefault).firstOrNull;

  /// العنوان ده لو لسه في الليستة، وإلا الافتراضي (زي عنوان اتختار لطلب
  /// وبعدين اتمسح)
  SavedAddressModel? addressOrDefault(int? id) =>
      state.items.where((address) => address.id == id).firstOrNull ??
      defaultAddress;

  /// الليستة اتجابت مرة على الأقل، حتى لو طلعت فاضية
  bool get hasLoaded => state.lastUpdated != null;

  /// العنوان ده عليه عملية شغالة، فالكارت بتاعه بيعرض لودر
  bool isBusy(SavedAddressModel address) =>
      state.metadata[_busyKey] == address.id;

  /// فيه عملية شغالة على أي عنوان، فالأزرار بتتقفل لحد ما تخلص
  bool get isAnyBusy => state.metadata.containsKey(_busyKey);

  Future<void> load() async {
    // من غير جلسة الطلب هيرجع 401 والانترسبتور هيرمي اليوزر على اللوجين
    final refreshToken = CacheManager.getRefreshTokenSync();
    if (refreshToken == null || refreshToken.isEmpty) return;

    final requestId = ++_requestId;
    // العناوين القديمة بتفضل ظاهرة لحد ما الجديدة توصل
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getAddresses();

    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          metadata: {},
        ),
      ),
      (items) => emit(
        state.copyWith(
          status: Status.success,
          items: items,
          metadata: {},
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  /// بترجع رسالة الخطأ لو فشل، و null لو نجح
  Future<String?> delete(SavedAddressModel address) {
    return _mutate(address, () => _dataSource.deleteAddress(address.id));
  }

  /// بترجع رسالة الخطأ لو فشل، و null لو نجح أو كان افتراضي أصلًا
  Future<String?> setDefault(SavedAddressModel address) async {
    if (address.isDefault) return null;
    return _mutate(address, () => _dataSource.setDefault(address.id));
  }

  /// بعد النجاح بنجيب الليستة تاني لأن الافتراضي ممكن يكون اتنقل لعنوان تاني.
  /// والـ 404 (العنوان اتمسح) والـ 409 (طلبين في نفس اللحظة) معناهم إن الليستة
  /// اللي معانا قديمة، فبنجيبها برضه. غير كده الليستة بتفضل زي ما هي
  Future<String?> _mutate(
    SavedAddressModel address,
    Future<Either<Failure, void>> Function() request,
  ) async {
    if (isAnyBusy) return null;
    emit(state.copyWith(metadata: {_busyKey: address.id}));

    final result = await request();

    if (isClosed) return null;

    final failure = result.isError ? result.throwError() : null;
    if (failure == null || isStaleListFailure(failure)) {
      await load();
    } else {
      emit(state.copyWith(metadata: {}));
    }
    return failure?.message;
  }

  /// الفشل ده معناه إن الليستة اللي معانا مش زي اللي على السيرفر
  static bool isStaleListFailure(Failure failure) =>
      failure.statusCode == 404 || failure.statusCode == 409;

  /// بتتنادى مع الخروج عشان الحساب اللي بعده مايشوفش عناوين اللي قبله
  void reset() {
    _requestId++;
    emit(const BaseState<SavedAddressModel>());
  }
}
