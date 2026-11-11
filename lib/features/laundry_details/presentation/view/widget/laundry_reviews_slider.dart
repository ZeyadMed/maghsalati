import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/loading_shimmer.dart';
import 'package:maghsalati/features/laundry_details/data/model/review_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/laundry_reviews_screen.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/laundry_reviews_cubit.dart';

/// تعليقات العملاء في تفاصيل المغسلة زي التطبيق الصيني: صورة واصلة لحرف
/// الشاشة وفوقها كروت بيضا بتلف لوحدها، والكروت اللي جنبها باينة من الحرفين
/// بيعرض أول صفحة من api/customer/laundries/{laundryId}/reviews، واللي
/// من غير تعليق بيتشال لأن الكارت معمول للكلام مش للنجوم بس
/// الدوس على أي كارت بيفتح شاشة التقييمات كلها بالفلترة
/// ولو مفيش تعليقات أو الطلب فشل السكشن كله بيختفي ومعاه المسافة اللي تحته
class LaundryReviewsSlider extends StatelessWidget {
  final int laundryId;
  final String laundryName;
  final double rating;
  final int ratingCount;

  const LaundryReviewsSlider({
    super.key,
    required this.laundryId,
    required this.laundryName,
    required this.rating,
    required this.ratingCount,
  });

  /// ارتفاع الصورة اللي ورا، والكارت جواها بمسافة من فوق وتحت
  static double get _height => 200.h;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LaundryReviewsCubit>()..getReviews(laundryId),
      child: BlocBuilder<LaundryReviewsCubit, BaseState<ReviewModel>>(
        builder: (context, state) {
          if (state.isInitial || state.isLoading) {
            return _withBottomGap(ShimmerBox(height: _height));
          }

          final reviews = state.items
              .where((review) => review.comment.isNotEmpty)
              .toList();
          if (state.isFailure || reviews.isEmpty) {
            return const SizedBox.shrink();
          }

          return _withBottomGap(_buildSlider(context, reviews));
        },
      ),
    );
  }

  Widget _buildSlider(BuildContext context, List<ReviewModel> reviews) {
    // تعليق واحد مالوش لازمة يلف
    final canSlide = reviews.length > 1;

    return SizedBox(
      height: _height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Assets.assetsImagesLaundry, fit: BoxFit.cover),
          // بيفتّح الصورة شوية عشان الكروت البيضا تبان فوقها
          ColoredBox(color: AppColors.whiteColor.withValues(alpha: 0.25)),
          CarouselSlider.builder(
            itemCount: reviews.length,
            options: CarouselOptions(
              height: _height,
              // أقل من 1 عشان الكروت اللي جنب باينة من الحرفين زي الديزاين
              viewportFraction: 0.8,
              autoPlay: canSlide,
              autoPlayInterval: const Duration(seconds: 4),
              enableInfiniteScroll: canSlide,
              scrollPhysics: canSlide
                  ? null
                  : const NeverScrollableScrollPhysics(),
            ),
            itemBuilder: (context, index, _) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 20.h),
              child: _ReviewSlide(
                review: reviews[index],
                onTap: () => _openReviews(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openReviews(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LaundryReviewsScreen(
          laundryId: laundryId,
          laundryName: laundryName,
          rating: rating,
          ratingCount: ratingCount,
        ),
      ),
    );
  }

  Widget _withBottomGap(Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: child,
    );
  }
}

/// كارت تعليق واحد: الاسم والنجوم فوق، والتعليق بين علامتين تنصيص،
/// والتاريخ تحت مكان اسم الخدمة في الديزاين لأن الباك مابيبعتهاش
/// الإطار الرفيع جوه الكارت نفس الصيني
class _ReviewSlide extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onTap;

  const _ReviewSlide({required this.review, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withValues(alpha: 0.94),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor4, width: 0.8),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildComment()),
              if (review.createdAt != null)
                Text(
                  DateFormat(
                    'd MMMM yyyy',
                    context.locale.toString(),
                  ).format(review.createdAt!),
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            review.customerName,
            style: TextStyles.darkRegular12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(8.w),
        for (var i = 0; i < 5; i++)
          Icon(
            i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 13.r,
            color: AppColors.lightOrangeColor,
          ),
      ],
    );
  }

  /// علامة الفتح فوق في أول السطر والقفل تحت في آخره،
  /// والـ Row بيقلبهم لوحده في العربي
  Widget _buildComment() {
    final quote = Icon(
      Icons.format_quote_rounded,
      size: 18.r,
      color: AppColors.greyColor5,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Transform.rotate(angle: math.pi, child: quote),
          ),
        ),
        Gap(4.w),
        Expanded(
          child: Center(
            child: Text(
              review.comment,
              style: TextStyles.darkRegular14.copyWith(height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Gap(4.w),
        Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: quote,
          ),
        ),
      ],
    );
  }
}
