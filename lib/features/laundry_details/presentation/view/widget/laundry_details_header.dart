import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';

/// صورة المغسلة فوق + زرار الرجوع + الاسم والتقييم على الصورة
class LaundryDetailsHeader extends StatelessWidget {
  final dynamic image;
  final String name;
  final double rating;
  final int ratingCount;
  final VoidCallback? onBack;

  const LaundryDetailsHeader({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.ratingCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // الصورة بتطلع تحت الاستاتس بار عشان تبان full bleed زي الديزاين
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: context.screenHeight * 0.2 + topPadding,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlexibleImage(source: image, borderRadius: 0, fit: BoxFit.cover),

          // تدرج داكن تحت عشان الاسم والتقييم يبانوا على الصورة
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  AppColors.blackColor.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          PositionedDirectional(
            top: topPadding + 12.h,
            start: 16.w,
            child: _buildBackButton(context),
          ),

          PositionedDirectional(
            bottom: 16.h,
            start: 16.w,
            end: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyles.whiteText(20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                _buildRatingRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: AppColors.blackColor.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back,
          size: 20.r,
          color: AppColors.whiteColor,
          // بيتقلب تلقائي في العربي فيبقى ناحية اليمين
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }

  /// النجمة + التقييم + عدد المقيمين
  Widget _buildRatingRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: 16.r, color: AppColors.lightOrangeColor),
        SizedBox(width: 4.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyles.boldStyle(14, color: AppColors.lightOrangeColor),
        ),
        SizedBox(width: 8.w),
        Text(
          '$ratingCount ${'review'.tr()}',
          style: TextStyles.whiteText(12, weight: FontWeight.w300),
        ),
      ],
    );
  }
}
