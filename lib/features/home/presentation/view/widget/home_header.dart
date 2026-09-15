import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';

class HomeHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String? Function(String?)? onSearchChanged;
  final VoidCallback? onLocationTap;
  final VoidCallback? onLogoTap;

  const HomeHeader({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onLocationTap,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        bottom: 20.h,
        start: 16.w,
        end: 16.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(28.r),
          bottomEnd: Radius.circular(28.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(),
          SizedBox(height: 18.h),
          _buildSearchField(),
        ],
      ),
    );
  }

  /// اللوجو على الشمال + الترحيب واسم التطبيق على اليمين
  Widget _buildTopRow() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'welcome'.tr()} 👋',
              style: TextStyles.whiteText(12, weight: FontWeight.w300),
            ),
            SizedBox(height: 2.h),
            Text('app_name'.tr(), style: TextStyles.whiteText(20)),
          ],
        ),

        const Spacer(),
        GestureDetector(
          onTap: onLogoTap,
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FlexibleImage(
              source: Assets.assetsImagesLogoLight,
              borderRadius: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  /// خانة البحث + زرار الموقع
  Widget _buildSearchField() {
    return Customtextfield(
      hintText: 'search_hint',
      textEditingController: searchController,
      onChanged: onSearchChanged,
      borderRadious: 14.r,
      prefix: Padding(
        padding: EdgeInsetsDirectional.only(start: 8.w, end: 4.w),
        child: GestureDetector(
          onTap: onLocationTap,
          child: SizedBox(
            width: 36.r,
            height: 36.r,
            child: Icon(
              Icons.location_on,
              size: 20.r,
              color: AppColors.redColor2,
            ),
          ),
        ),
      ),
    );
  }
}
