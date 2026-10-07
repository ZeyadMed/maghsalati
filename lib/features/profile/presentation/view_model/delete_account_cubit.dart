import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/session.dart';
import 'package:maghsalati/features/profile/data/profile_data_source.dart';

/// بتحذف الحساب من الباك، ولما تنجح بتمسح الجلسة من الجهاز
/// عشان مايفضلش توكن ولا بيانات لحساب اتحذف
class DeleteAccountCubit extends Cubit<BaseState<void>> {
  final ProfileDataSource _dataSource;

  DeleteAccountCubit(this._dataSource) : super(const BaseState<void>());

  Future<void> deleteAccount() async {
    if (state.isLoading) return;
    emit(const BaseState(status: Status.loading));

    final result = await _dataSource.deleteAccount();

    // بنستخدم isError بدل fold عشان مسح الجلسة محتاج await
    if (result.isError) {
      if (isClosed) return;
      emit(
        BaseState(
          status: Status.failure,
          errorMessage: result.throwError().message,
        ),
      );
      return;
    }

    // الحساب اتحذف خلاص، فبنمسح الجلسة حتى لو الشاشة اتقفلت
    await Session.clear();
    if (isClosed) return;
    emit(const BaseState(status: Status.success));
  }
}
