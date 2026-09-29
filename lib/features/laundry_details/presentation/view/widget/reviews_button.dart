import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/laundry_reviews_screen.dart';

/// كارت "عرض التقييمات" في تفاصيل المغسلة، بيفتح شاشة التقييمات
/// نفس شكل كارت مواعيد العمل عشان الاتنين يبانوا مع بعض
class ReviewsButton extends StatelessWidget {
  final int laundryId;
  final String laundryName;
  final double rating;
  final int ratingCount;

  const ReviewsButton({
    super.key,
    required this.laundryId,
    required this.laundryName,
    required this.rating,
    required this.ratingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LaundryReviewsScreen(
              laundryId: laundryId,
              laundryName: laundryName,
              rating: rating,
              ratingCount: ratingCount,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.star_outline_rounded,
                size: 20.r,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: LocalizedLabel(
                  text: 'show_reviews',
                  style: TextStyles.darkBold14,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: AppColors.greyColor2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
