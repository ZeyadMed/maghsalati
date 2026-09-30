import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/laundry_details/data/model/review_model.dart';

abstract interface class LaundryReviewsDataSource {
  Future<Either<Failure, ReviewsPageModel>> getReviews({
    required int laundryId,
    required int pageIndex,
    required int pageSize,
    int? rating,
  });

  /// تقييم العميل للمغسلة بعد ما الطلب يتسلّم، والتعليق اختياري
  Future<Either<Failure, void>> addReview({
    required int laundryId,
    required int rating,
    String? comment,
  });
}

class LaundryReviewsDataSourceImpl implements LaundryReviewsDataSource {
  final GenericDataSource _genericDataSource;
  LaundryReviewsDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, ReviewsPageModel>> getReviews({
    required int laundryId,
    required int pageIndex,
    required int pageSize,
    int? rating,
  }) {
    return _genericDataSource.fetchResult<ReviewsPageModel>(
      endpoint: Endpoints.laundryReviews(laundryId),
      queryParameters: {
        'PageIndex': pageIndex,
        'PageSize': pageSize,
        // من غير rating الباك بيرجع كل التقييمات
        'rating': ?rating,
      },
      fromJson: ReviewsPageModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, void>> addReview({
    required int laundryId,
    required int rating,
    String? comment,
  }) async {
    final result = await _genericDataSource.postData<Map<String, dynamic>>(
      endpoint: Endpoints.reviews,
      data: {'laundryId': laundryId, 'rating': rating, 'comment': ?comment},
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
