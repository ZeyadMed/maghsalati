import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_reviews_data_source.dart';
import 'package:maghsalati/features/laundry_details/data/model/review_model.dart';

/// بتجيب تقييمات المغسلة صفحة صفحة، وبتفلتر بعدد النجوم
/// state.page هي الصفحة اللي عليها الدور، و hasReachedMax لما الصفحات تخلص
class LaundryReviewsCubit extends Cubit<BaseState<ReviewModel>> {
  final LaundryReviewsDataSource _dataSource;

  static const int _pageSize = 10;

  int? _laundryId;

  /// الفلتر الحالي من 1 لـ 5، و null يعني الكل
  int? _rating;
  int? get rating => _rating;

  /// لو الفلتر اتغير وفيه صفحة لسه بتحمل، نتيجتها القديمة بتتجاهل
  int _requestId = 0;

  LaundryReviewsCubit(this._dataSource)
    : super(const BaseState<ReviewModel>());

  /// أول صفحة، بتتنادى أول ما الشاشة تفتح ومع السحب للتحديث
  Future<void> getReviews(int laundryId) async {
    _laundryId = laundryId;
    final requestId = ++_requestId;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getReviews(
      laundryId: laundryId,
      pageIndex: 1,
      pageSize: _pageSize,
      rating: _rating,
    );

    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          status: Status.success,
          items: page.reviews,
          page: 2,
          hasReachedMax: page.isLastPage,
        ),
      ),
    );
  }

  /// بتغير الفلتر وبتجيب من أول صفحة، والتقييمات القديمة بتتمسح
  /// عشان مايبانش تقييمات مش من الفلتر الجديد وهي بتحمل
  Future<void> filterByRating(int? rating) async {
    final laundryId = _laundryId;
    if (laundryId == null || rating == _rating) return;
    _rating = rating;
    emit(state.copyWith(items: [], hasReachedMax: false));
    await getReviews(laundryId);
  }

  /// الصفحة اللي بعدها، بتتنادى لما اليوزر يوصل لآخر الليستة
  Future<void> loadMore() async {
    final laundryId = _laundryId;
    if (laundryId == null ||
        state.hasReachedMax ||
        state.isLoading ||
        state.isLoadingMore) {
      return;
    }

    final requestId = _requestId;
    emit(state.copyWith(status: Status.isLoadingMore));

    final result = await _dataSource.getReviews(
      laundryId: laundryId,
      pageIndex: state.page,
      pageSize: _pageSize,
      rating: _rating,
    );

    if (isClosed || requestId != _requestId) return;

    result.fold(
      // الليستة بتفضل زي ما هي، ولما يعمل سكرول تاني بيحاول تاني
      (failure) => emit(
        state.copyWith(
          status: Status.isLoadingMoreFauilare,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: Status.success,
          items: [...state.items, ...page.reviews],
          page: state.page + 1,
          hasReachedMax: page.isLastPage,
        ),
      ),
    );
  }
}
