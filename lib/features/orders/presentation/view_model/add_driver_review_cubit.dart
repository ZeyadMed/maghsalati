import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

/// بتبعت تقييم العميل لمندوب رحلة خلصت على api/customer/driver-reviews
/// بتتعمل جديدة مع كل شاشة تقييم
class AddDriverReviewCubit extends Cubit<BaseState<void>> {
  final OrdersDataSource _dataSource;

  AddDriverReviewCubit(this._dataSource) : super(const BaseState<void>());

  Future<void> submit({
    required int tripId,
    required int rating,
    String? comment,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.addDriverReview(
      tripId: tripId,
      rating: rating,
      comment: comment,
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
