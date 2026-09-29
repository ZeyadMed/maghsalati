/// تقييم واحد راجع من api/customer/laundries/{laundryId}/reviews
class ReviewModel {
  final int id;

  /// من 1 لـ 5
  final int rating;
  final String comment;
  final String customerName;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.customerName,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: ((json['rating'] as num?)?.toInt() ?? 0).clamp(0, 5),
      comment: json['comment']?.toString().trim() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

/// صفحة من التقييمات، الـ API بيرجعها جوه data ومعاها بيانات الصفحات
class ReviewsPageModel {
  final int pageIndex;
  final int totalPages;
  final List<ReviewModel> reviews;

  const ReviewsPageModel({
    required this.pageIndex,
    required this.totalPages,
    required this.reviews,
  });

  /// مفيش صفحات تانية بعد دي
  bool get isLastPage => pageIndex >= totalPages;

  factory ReviewsPageModel.fromJson(Map<String, dynamic> json) {
    return ReviewsPageModel(
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      reviews: ((json['data'] as List?) ?? [])
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
