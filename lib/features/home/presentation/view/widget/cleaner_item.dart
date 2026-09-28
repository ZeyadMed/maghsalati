import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/home/data/model/nearby_laundry_model.dart';

class CleanerItem extends StatelessWidget {
  final NearbyLaundryModel laundry;

  /// بيتنادى في الحالتين، واللي بيبعته هو اللي بيقرر يفتح التفاصيل
  /// ولا مواعيد العمل حسب [NearbyLaundryModel.isAvailableNow]
  final VoidCallback? onTap;

  const CleanerItem({super.key, required this.laundry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAvailable = laundry.isAvailableNow;
    return Opacity(
      opacity: isAvailable ? 1 : 0.5,
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderImage(),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRatingRow(),
                      if (laundry.fullAddress.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _buildAddressRow(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// صورة المغسلة + المسافة والتوفر فوق + الاسم تحت
  Widget _buildHeaderImage() {
    return SizedBox(
      height: 150.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlexibleImage(
            // لو المغسلة مالهاش صورة بنعرض الصورة الافتراضية
            source: laundry.imageUrl.isEmpty
                ? Assets.assetsImagesCleaner
                : laundry.imageUrl,
            borderRadius: 0,
            fit: BoxFit.cover,
          ),
          // تدرج داكن تحت عشان الاسم يبان على الصورة
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  AppColors.blackColor.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          PositionedDirectional(
            bottom: 10.h,
            start: 12.w,
            end: 12.w,
            child: Text(
              laundry.name,
              style: TextStyles.whiteBold15,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PositionedDirectional(
            top: 10.h,
            end: 10.w,
            child: Row(
              children: [
                _buildBadge(
                  label: laundry.isAvailableNow
                      ? 'available'.tr()
                      : 'not_available'.tr(),
                  color: laundry.isAvailableNow
                      ? AppColors.greenColor
                      : AppColors.redColor2,
                ),
                SizedBox(width: 6.w),
                _buildBadge(
                  label:
                      '${laundry.distanceKm.toStringAsFixed(1)} ${'km'.tr()}',
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label, style: TextStyles.whiteText(11)),
    );
  }

  /// التقييم وعدد المقيمين
  Widget _buildRatingRow() {
    return Row(
      children: [
        Icon(Icons.star, size: 16.r, color: AppColors.lightOrangeColor),
        SizedBox(width: 4.w),
        Text(
          laundry.averageRating.toStringAsFixed(1),
          style: TextStyles.boldStyle(14, color: AppColors.lightOrangeColor),
        ),
        const Spacer(),
        Text(
          '${laundry.reviewsCount} ${'review'.tr()}',
          style: TextStyles.greyLight10.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }

  /// المدينة والعنوان
  Widget _buildAddressRow() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16.r,
          color: AppColors.primaryColor,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            laundry.fullAddress,
            style: TextStyles.greyLight10.copyWith(fontSize: 12.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
