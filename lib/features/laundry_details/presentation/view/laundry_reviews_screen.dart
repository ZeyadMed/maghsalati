import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/data/model/review_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/review_card.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/laundry_reviews_cubit.dart';

/// شاشة تقييمات المغسلة: ملخص التقييم فوق، وشيبس للفلترة بالنجوم،
/// وتحتهم التقييمات جاية من api/customer/laundries/{laundryId}/reviews صفحة صفحة
class LaundryReviewsScreen extends StatefulWidget {
  final int laundryId;
  final String laundryName;
  final double rating;
  final int ratingCount;

  const LaundryReviewsScreen({
    super.key,
    required this.laundryId,
    required this.laundryName,
    required this.rating,
    required this.ratingCount,
  });

  @override
  State<LaundryReviewsScreen> createState() => _LaundryReviewsScreenState();
}

class _LaundryReviewsScreenState extends State<LaundryReviewsScreen> {
  final LaundryReviewsCubit _cubit = getIt<LaundryReviewsCubit>();

  /// null = الكل، وبعده من 5 لـ 1
  static const List<int?> _ratingFilters = [null, 5, 4, 3, 2, 1];

  @override
  void initState() {
    super.initState();
    _cubit.getReviews(widget.laundryId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _refresh() => _cubit.getReviews(widget.laundryId);

  /// بتتنادى بعد الفريم عشان الـ emit مايحصلش وسط الـ build
  void _loadMoreAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _cubit.loadMore());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('reviews'.tr(), style: TextStyles.darkBold16),
            Text(
              widget.laundryName,
              style: TextStyles.darkRegular12.copyWith(
                color: AppColors.greyColor3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: BlocBuilder<LaundryReviewsCubit, BaseState<ReviewModel>>(
        bloc: _cubit,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap(16.h),
            _buildSummary(),
            Gap(14.h),
            _buildFilters(),
            Gap(8.h),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: _refresh,
                child: _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// متوسط التقييم وعدد المقيمين، جايين من كارت المغسلة
  Widget _buildSummary() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            widget.rating.toStringAsFixed(1),
            style: TextStyles.boldStyle(32, color: AppColors.blackColor),
          ),
          Gap(10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < widget.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 18.r,
                    color: AppColors.lightOrangeColor,
                  ),
                ),
              ),
              Gap(2.h),
              Text(
                '${widget.ratingCount} ${'review'.tr()}',
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// الكل + شيب لكل عدد نجوم، والمختار بيتلون أزرق
  Widget _buildFilters() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _ratingFilters.length,
        separatorBuilder: (_, _) => Gap(8.w),
        itemBuilder: (context, index) {
          final rating = _ratingFilters[index];
          final isSelected = _cubit.rating == rating;
          final foreground = isSelected
              ? AppColors.whiteColor
              : AppColors.blackColor;

          return InkWell(
            onTap: () => _cubit.filterByRating(rating),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.whiteColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                ),
              ),
              child: rating == null
                  ? Text(
                      'all'.tr(),
                      style: TextStyles.boldStyle(12, color: foreground),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$rating',
                          style: TextStyles.boldStyle(12, color: foreground),
                        ),
                        Gap(4.w),
                        Icon(
                          Icons.star_rounded,
                          size: 14.r,
                          color: isSelected
                              ? AppColors.whiteColor
                              : AppColors.lightOrangeColor,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BaseState<ReviewModel> state) {
    // أول تحميل أو فشل ومفيش تقييمات قديمة نعرضها
    if (state.items.isEmpty) {
      if (state.isFailure) return _buildScrollableCenter(_buildError(state));
      if (!state.isSuccess) return _buildScrollableCenter(_buildLoading());
      return _buildScrollableCenter(_buildEmpty());
    }

    final showLoader = !state.hasReachedMax;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: state.items.length + (showLoader ? 1 : 0),
      separatorBuilder: (_, _) => Gap(12.h),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          // اللودر آخر الليستة، أول ما يترسم بنجيب الصفحة اللي بعدها
          _loadMoreAfterFrame();
          return _buildLoading();
        }
        return ReviewCard(review: state.items[index]);
      },
    );
  }

  /// الحالات اللي في النص لازم تبقى جوه scrollable عشان السحب للتحديث يشتغل
  Widget _buildScrollableCenter(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildError(BaseState<ReviewModel> state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 56.r, color: AppColors.greyColor5),
          Gap(12.h),
          Text(
            state.errorMessage ?? 'try_again'.tr(),
            style: TextStyles.darkBold16,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _refresh,
            child: Text(
              'try_again'.tr(),
              style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  /// لو فيه فلتر الرسالة بتقول إن مفيش تقييمات بالنجوم دي بس
  Widget _buildEmpty() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.rate_review_outlined,
          size: 56.r,
          color: AppColors.greyColor4,
        ),
        Gap(12.h),
        Text(
          _cubit.rating == null
              ? 'no_reviews'.tr()
              : 'no_reviews_for_rating'.tr(),
          style: TextStyles.darkRegular14.copyWith(
            color: AppColors.greyColor3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
