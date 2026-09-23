import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/helpers/logger.dart';
import 'package:maghsalati/features/auth/logout/data/logout_data_source.dart';
import 'package:maghsalati/features/auth/logout/presentation/logic/logout_event.dart';

class LogoutBloc extends Bloc<LogoutEvent, BaseState<void>> {
  final LogoutDataSource _logoutDataSource;

  LogoutBloc(this._logoutDataSource) : super(const BaseState()) {
    on<LogoutEvent>(_onLogoutEvent);
  }

  Future<void> _onLogoutEvent(
    LogoutEvent event,
    Emitter<BaseState<void>> emit,
  ) async {
    emit(const BaseState(status: Status.loading));

    final refreshToken = CacheManager.getRefreshTokenSync();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final result = await _logoutDataSource.logout(refreshToken: refreshToken);
      // لو الباك فشل بنكمل الخروج برضه، مش هنحبس المستخدم جوه الحساب
      // عشان النت واقع أو التوكن منتهي
      result.fold(
        (failure) => loggerWarn('Logout request failed: ${failure.message}'),
        (_) => logger('Logged out from backend'),
      );
    }

    // لازم نمسح التوكنين مع بعض، وإلا الـ refreshToken هيفضل محفوظ
    // والسبلاش هيرجّع المستخدم على الهوم تاني.
    await CacheManager.clearTokens();
    await CacheManager.clearUserData();

    emit(const BaseState(status: Status.success));
  }
}
