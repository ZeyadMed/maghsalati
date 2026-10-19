import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/data/profile_data_source.dart';

/// بتجيب بيانات العميل من api/customer/profile وبتحطها في state.data
class ProfileCubit extends Cubit<BaseState<UserModel>> {
  final ProfileDataSource _dataSource;

  ProfileCubit(this._dataSource) : super(const BaseState<UserModel>());

  Future<void> getProfile() async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getProfile();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (user) => setUser(user),
    );
  }

  /// بعد ما التعديل يتحفظ بنحط النسخة الجديدة على طول من غير طلب تاني
  /// والاسم والرقم بيتحفظوا عشان بيانات الاستلام في تأكيد الطلب
  void setUser(UserModel user) {
    CacheManager.saveUserContact(name: user.name, phone: user.phoneNumber);
    emit(state.copyWith(status: Status.success, data: user));
  }
}
