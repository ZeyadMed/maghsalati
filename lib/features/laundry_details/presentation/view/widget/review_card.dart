import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/data/model/review_model.dart';

/// كارت تقييم واحد: اسم العميل والتاريخ والنجوم وتحتهم التعليق
class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          if (review.comment.isNotEmpty) ...[
            Gap(10.h),
            Text(
              review.comment,
              style: TextStyles.darkRegular14.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name = review.customerName;

    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
          child: Text(
            name.isEmpty ? '?' : name.characters.first.toUpperCase(),
            style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
          ),
        ),
        Gap(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyles.darkBold14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (review.createdAt != null) ...[
                Gap(2.h),
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
            ],
          ),
        ),
        Gap(8.w),
        _buildStars(),
      ],
    );
  }

  /// النجوم المليانة على قد التقييم والباقي فاضية
  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < review.rating
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          size: 16.r,
          color: AppColors.lightOrangeColor,
        ),
      ),
    );
  }
}
