import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/home/data/model/nearby_laundry_model.dart';
import 'package:maghsalati/features/home/data/nearby_laundries_data_source.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';

/// بتجيب المغاسل القريبة بإحداثيات المستخدم، وبتعيد الجلب لوحدها
/// لما الموقع يتجاب أو يتغير (زي لما اليوزر يدوس على العنوان ويسمح بالصلاحية)
class NearbyLaundriesCubit extends Cubit<BaseState<NearbyLaundryModel>> {
  final NearbyLaundriesDataSource _dataSource;
  final LocationController _location;

  /// أقل وقت بين كل طلب بحث والتاني وهو بيكتب
  static const _searchThrottle = Duration(seconds: 1);

  String _search = '';
  Timer? _searchThrottleTimer;

  /// آخر نص اتكتب جوه فترة الـ throttle، بيتبعت أول ما الفترة تخلص
  /// عشان النتيجة تبقى دايماً على آخر حاجة كتبها
  String? _pendingSearch;

  /// الإحداثيات اللي آخر طلب اتبعت بيها، عشان مانعيدش الجلب على الفاضي
  (double?, double?)? _fetchedFor;

  /// لو كذا طلب راحوا ورا بعض (وهو بيكتب في البحث) بناخد نتيجة آخر واحد بس
  int _requestId = 0;

  NearbyLaundriesCubit(this._dataSource, this._location)
    : super(const BaseState<NearbyLaundryModel>()) {
    _location.addListener(_onLocationChanged);
  }

  /// بتتنادى أول ما الشاشة تفتح
  void start() {
    _location.load();
    // لو الموقع اتجاب قبل كده load مابتعملش حاجة، فبنجيب على طول.
    // غير كده الـ listener هو اللي هيجيب أول ما الموقع يوصل
    if (!_location.isLoading) getLaundries();
  }

  void _onLocationChanged() {
    if (_location.isLoading) return;
    if (_fetchedFor == (_location.latitude, _location.longitude)) return;
    getLaundries();
  }

  /// throttle: أول حرف بيبعت على طول، وبعدها طلب واحد بالكتير كل ثانية
  /// والنص بيروح للباك في query param اسمه search
  void search(String query) {
    final trimmed = query.trim();
    if (_searchThrottleTimer?.isActive ?? false) {
      _pendingSearch = trimmed;
      return;
    }
    _runSearch(trimmed);
  }

  void _runSearch(String query) {
    _pendingSearch = null;
    _searchThrottleTimer = Timer(_searchThrottle, () {
      final pending = _pendingSearch;
      if (pending != null) _runSearch(pending);
    });

    if (query == _search) return;
    _search = query;
    getLaundries();
  }

  Future<void> getLaundries() async {
    final requestId = ++_requestId;
    _fetchedFor = (_location.latitude, _location.longitude);
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getNearbyLaundries(
      lat: _location.latitude,
      lng: _location.longitude,
      search: _search,
    );

    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (data) => emit(state.copyWith(status: Status.success, items: data)),
    );
  }

  @override
  Future<void> close() {
    _searchThrottleTimer?.cancel();
    _location.removeListener(_onLocationChanged);
    return super.close();
  }
}
