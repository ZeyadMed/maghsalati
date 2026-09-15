import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/home/presentation/view/widget/timing_row.dart';

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
    return IgnorePointer(
      ignoring: !isAvailable,
      child: Opacity(
        opacity: isAvailable ? 1 : 0.5,
        child: GestureDetector(
          onTap: isAvailable ? onTap : null,
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
                      TimingRow(
                        pickUpTime: pickUpTime,
                        deliveryTime: deliveryTime,
                      ),
                      SizedBox(height: 12.h),
                      _buildServicesRow(),
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
            bottom: 10.h,
            start: 12.w,
            child: Text(
              name,
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
          rating.toStringAsFixed(1),
          style: TextStyles.boldStyle(14, color: AppColors.lightOrangeColor),
        ),
        const Spacer(),
        Text(
          '$ratingCount ${'review'.tr()}',
          style: TextStyles.greyLight10.copyWith(fontSize: 12.sp),
        ),
      ],
    );
  }

  /// سعر التوصيل + ليست الخدمات
  Widget _buildServicesRow() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final service in services) ...[
                  if (service != services.first) SizedBox(width: 6.w),
                  _buildServiceChip(service),
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '${'delivery_price'.tr()} $deliveryPrice ${'currency'.tr()}',
          style: TextStyles.boldStyle(13, color: AppColors.primaryColor),
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
