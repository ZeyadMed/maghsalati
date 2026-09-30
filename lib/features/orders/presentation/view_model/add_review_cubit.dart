import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_reviews_data_source.dart';

/// بتبعت تقييم العميل للمغسلة بعد ما الطلب يتسلّم على api/customer/reviews
/// بتتعمل جديدة مع كل شيت تقييم
class AddReviewCubit extends Cubit<BaseState<void>> {
  final LaundryReviewsDataSource _dataSource;

  AddReviewCubit(this._dataSource) : super(const BaseState<void>());

  Future<void> submit({
    required int laundryId,
    required int rating,
    String? comment,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.addReview(
      laundryId: laundryId,
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
