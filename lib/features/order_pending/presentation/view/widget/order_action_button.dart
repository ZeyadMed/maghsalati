import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// زرار شاشات نتيجة الطلب (قبول أو رفض)
/// filled يعني مليان بلون البراند، والعكس بيبقى خلفية فاتحة وخط أزرق
class OrderActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  const OrderActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled
            ? AppColors.primaryColor
            : AppColors.primaryColor.withValues(alpha: 0.12),
        foregroundColor: filled
            ? AppColors.whiteColor
            : AppColors.primaryColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyles.darkBold16.copyWith(
          color: filled ? AppColors.whiteColor : AppColors.primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
