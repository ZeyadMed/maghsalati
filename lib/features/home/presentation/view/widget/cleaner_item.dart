import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';

class CleanerItem extends StatelessWidget {
  final String name;
  final dynamic image;
  final double distance;
  final bool isAvailable;
  final double rating;
  final int ratingCount;
  final String pickUpTime;
  final String deliveryTime;
  final List<String> services;
  final num deliveryPrice;
  final VoidCallback? onTap;

  const CleanerItem({
    super.key,
    required this.name,
    required this.image,
    required this.distance,
    required this.isAvailable,
    required this.rating,
    required this.ratingCount,
    required this.pickUpTime,
    required this.deliveryTime,
    required this.services,
    required this.deliveryPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                  SizedBox(height: 12.h),
                  _buildTimingRow(),
                  SizedBox(height: 12.h),
                  _buildServicesRow(),
                ],
              ),
            ),
          ],
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
          FlexibleImage(source: image, borderRadius: 0, fit: BoxFit.cover),
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
            top: 10.h,
            start: 10.w,
            child: Row(
              children: [
                _buildBadge(
                  label: isAvailable ? 'available'.tr() : 'not_available'.tr(),
                  color: isAvailable
                      ? AppColors.greenColor
                      : AppColors.redColor2,
                ),
                SizedBox(width: 6.w),
                _buildBadge(
                  label: '${distance.toStringAsFixed(1)} ${'km'.tr()}',
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
          PositionedDirectional(
            bottom: 10.h,
            end: 12.w,
            child: Text(
              name,
              style: TextStyles.whiteBold15,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        Text(
          '$ratingCount ${'review'.tr()}',
          style: TextStyles.greyLight10.copyWith(fontSize: 12.sp),
        ),
        const Spacer(),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyles.boldStyle(14, color: AppColors.lightOrangeColor),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.star, size: 16.r, color: AppColors.lightOrangeColor),
      ],
    );
  }

  /// بوكسين الاستلام والتسليم
  Widget _buildTimingRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTimingBox(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.orangeColor,
            title: 'pick_up'.tr(),
            value: pickUpTime,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildTimingBox(
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.redColor2,
            title: 'delivery'.tr(),
            value: deliveryTime,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.semiWhiteColor3,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyles.greyLight10.copyWith(fontSize: 11.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyles.darkBold12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(icon, size: 20.r, color: iconColor),
        ],
      ),
    );
  }

  /// سعر التوصيل + ليست الخدمات
  Widget _buildServicesRow() {
    return Row(
      children: [
        Text(
          '${'delivery_price'.tr()} $deliveryPrice ${'currency'.tr()}',
          style: TextStyles.boldStyle(13, color: AppColors.primaryColor),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                for (final service in services) ...[
                  _buildServiceChip(service),
                  SizedBox(width: 6.w),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        service,
        style: TextStyles.boldStyle(
          11,
          color: AppColors.primaryColor,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}
