import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/data/saved_addresses_data_source.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

/// بتبعت فورم العنوان (إضافة أو تعديل)، وبتتعمل جديدة مع كل فورم
/// لما الحفظ ينجح بتجيب ليستة العناوين من السيرفر الأول وبعدين تبعت success،
/// عشان الشاشة اللي راجعين لها تلاقي الافتراضي الجديد جاهز.
/// state.data فيه العنوان بعد الحفظ زي ما رجع في الليستة
class SaveAddressCubit extends Cubit<BaseState<SavedAddressModel>> {
  final SavedAddressesDataSource _dataSource;
  final SavedAddressesCubit _addresses;

  SaveAddressCubit(this._dataSource, this._addresses)
    : super(const BaseState<SavedAddressModel>());

  /// [addressId] بيبقى null في الإضافة
  Future<void> save(SavedAddressRequest request, {int? addressId}) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    if (addressId == null) {
      final result = await _dataSource.addAddress(request);
      if (isClosed) return;
      await result.fold(_onFailure, (added) => _onSaved(added.id, added));
    } else {
      final result = await _dataSource.updateAddress(addressId, request);
      if (isClosed) return;
      await result.fold(_onFailure, (_) => _onSaved(addressId, null));
    }
  }

  Future<void> _onFailure(Failure failure) async {
    // الـ 400 رسالته بتتعرض زي ما هي، والـ 404/409 معناهم إن الليستة قديمة
    if (SavedAddressesCubit.isStaleListFailure(failure)) _addresses.load();
    emit(state.copyWith(status: Status.failure, errorMessage: failure.message));
  }

  Future<void> _onSaved(int savedId, SavedAddressModel? fallback) async {
    await _addresses.load();
    if (isClosed) return;

    // النسخة اللي في الليستة هي اللي فيها isDefault بعد قواعد السيرفر
    // (زي إن أول عنوان بيبقى افتراضي حتى لو مابعتناش true)
    final saved =
        _addresses.state.items.where((a) => a.id == savedId).firstOrNull ??
        fallback;
    emit(state.copyWith(status: Status.success, data: saved));
  }
}
