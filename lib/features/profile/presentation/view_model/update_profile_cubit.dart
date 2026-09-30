import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/data/profile_data_source.dart';

/// بتبعت تعديلات الملف الشخصي، ولما تنجح بتحط النسخة المعدلة في state.data
/// عشان الشاشة ترجعها لشاشة حسابي
class UpdateProfileCubit extends Cubit<BaseState<UserModel>> {
  final ProfileDataSource _dataSource;

  UpdateProfileCubit(this._dataSource) : super(const BaseState<UserModel>());

  Future<void> updateProfile(UserModel user) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.updateProfile(user);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (_) => emit(state.copyWith(status: Status.success, data: user)),
    );
  }
}
