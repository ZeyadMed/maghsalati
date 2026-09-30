import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

/// بتبعت رد العميل على تعديل المغسلة، بتتعمل جديدة مع كل شيت مراجعة
/// state.data بيبقى الرد اللي اتبعت، عشان اللودينج يظهر على الزرار اللي اتداس بس
class AdjustmentResponseCubit extends Cubit<BaseState<bool>> {
  final OrdersDataSource _dataSource;

  AdjustmentResponseCubit(this._dataSource) : super(const BaseState<bool>());

  Future<void> respond({required int orderId, required bool approve}) async {
    // رد واحد في المرة عشان الدبل كليك مايبعتش ردين
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading, data: approve));

    final result = await _dataSource.respondToAdjustment(
      orderId: orderId,
      approve: approve,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (_) => emit(state.copyWith(status: Status.success)),
    );
  }
}
