import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/profile/data/app_info_data_source.dart';
import 'package:maghsalati/features/profile/data/model/privacy_policy_model.dart';

/// بتجيب سياسة الخصوصية من api/auth/privacy-policy وبتحطها في state.data
class PrivacyPolicyCubit extends Cubit<BaseState<PrivacyPolicyModel>> {
  final AppInfoDataSource _dataSource;

  PrivacyPolicyCubit(this._dataSource)
    : super(const BaseState<PrivacyPolicyModel>());

  Future<void> getPrivacyPolicy() async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getPrivacyPolicy();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (policy) => emit(state.copyWith(status: Status.success, data: policy)),
    );
  }
}
