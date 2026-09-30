import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// رسالة الخطأ في نص الشاشة ومعاها زرار حاول مرة أخرى
class RetryErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const RetryErrorView({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56.r, color: AppColors.greyColor5),
            Gap(12.h),
            Text(
              message ?? 'try_again'.tr(),
              style: TextStyles.darkBold16,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'try_again'.tr(),
                style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
