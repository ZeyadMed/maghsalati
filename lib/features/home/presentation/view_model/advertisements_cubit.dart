import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/home/data/advertisements_data_source.dart';
import 'package:maghsalati/features/home/data/model/advertisement_model.dart';

/// بتجيب بانرات الهوم من api/auth/advertisements وبتحطها في state.items
class AdvertisementsCubit extends Cubit<BaseState<AdvertisementModel>> {
  final AdvertisementsDataSource _dataSource;

  AdvertisementsCubit(this._dataSource)
    : super(const BaseState<AdvertisementModel>());

  Future<void> getAdvertisements() async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getAdvertisements();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      // الإعلان اللي مالوش صورة مالوش لازمة في البانر
      (ads) => emit(
        state.copyWith(
          status: Status.success,
          items: ads.where((ad) => ad.imageUrl.isNotEmpty).toList(),
        ),
      ),
    );
  }
}
