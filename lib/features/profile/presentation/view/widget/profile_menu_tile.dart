import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// سطر من سطور القايمة في شاشة حسابي
/// الأيقونة جوا مربع ملون، والاسم جنبها، والسهم في آخر السطر
class ProfileMenuTile extends StatelessWidget {
  final IconData icon;

  /// لون الأيقونة، والخلفية بتتعمل منه بشفافية خفيفة
  final Color iconColor;

  /// مفتاح الترجمة بتاع اسم السطر
  final String titleKey;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.titleKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              _buildIconBox(),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  titleKey.tr(),
                  style: TextStyles.darkBold14.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: AppColors.greyColor5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11.r),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20.r, color: iconColor),
    );
  }
}
