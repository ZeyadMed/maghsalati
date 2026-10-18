import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// علامة "افتراضي" جنب اسم العنوان الافتراضي
class DefaultAddressBadge extends StatelessWidget {
  const DefaultAddressBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.greenColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'default_address'.tr(),
        style: TextStyles.darkBold12.copyWith(
          color: AppColors.greenColor,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
