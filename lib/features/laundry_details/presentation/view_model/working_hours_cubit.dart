import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_services_data_source.dart';
import 'package:maghsalati/features/laundry_details/data/model/working_hours_model.dart';

/// بتجيب مواعيد عمل المغسلة وهل هي مفتوحة دلوقتي
class WorkingHoursCubit extends Cubit<BaseState<WorkingHoursModel>> {
  final LaundryServicesDataSource _dataSource;

  WorkingHoursCubit(this._dataSource)
    : super(const BaseState<WorkingHoursModel>());

  Future<void> getWorkingHours(int laundryId) async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getWorkingHours(laundryId);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (data) => emit(state.copyWith(status: Status.success, data: data)),
    );
  }
}
