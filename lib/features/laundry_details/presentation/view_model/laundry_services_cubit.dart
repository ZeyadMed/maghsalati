import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_services_data_source.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';

/// بتجيب أقسام خدمات المغسلة وجواها القطع بأسعارها
class LaundryServicesCubit extends Cubit<BaseState<ServiceCategoryModel>> {
  final LaundryServicesDataSource _dataSource;

  LaundryServicesCubit(this._dataSource)
    : super(const BaseState<ServiceCategoryModel>());

  Future<void> getServices(int laundryId) async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getServices(laundryId);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (data) => emit(state.copyWith(status: Status.success, items: data)),
    );
  }
}
