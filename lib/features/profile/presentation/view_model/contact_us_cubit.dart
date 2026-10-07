import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/profile/data/app_info_data_source.dart';
import 'package:maghsalati/features/profile/data/model/contact_info_model.dart';

/// بتجيب أرقام وإيميل التواصل من api/auth/contacts وبتحطهم في state.data
class ContactUsCubit extends Cubit<BaseState<ContactInfoModel>> {
  final AppInfoDataSource _dataSource;

  ContactUsCubit(this._dataSource) : super(const BaseState<ContactInfoModel>());

  Future<void> getContacts() async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getContacts();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (contacts) =>
          emit(state.copyWith(status: Status.success, data: contacts)),
    );
  }
}
