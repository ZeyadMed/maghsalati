import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// كارت أبيض بظل خفيف، نفس شكل كروت الطلبات عشان الشاشات تبقى متسقة.
/// لو ليه [title] بيبان فوقه وجنبه [trailing] (عدد القطع أو شارة الحالة)
class OrderSectionCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;

  const OrderSectionCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final title = this.title;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyles.darkBold16.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[Gap(12.w), trailing!],
              ],
            ),
            Gap(14.h),
          ],
          child,
        ],
      ),
    );
  }
}

/// سطر معلومة: أيقونة في مربع ملون وجنبها العنوان والقيمة، وممكن زرار في الآخر
class OrderInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? action;

  const OrderInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 22.r, color: AppColors.primaryColor),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
              ),
              Gap(2.h),
              Text(value, style: TextStyles.darkBold14),
            ],
          ),
        ),
        if (action != null) ...[Gap(8.w), action!],
      ],
    );
  }
}

/// زرار دايري صغير بأيقونة (اتصال - نسخ)
class OrderCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const OrderCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 38.r,
            child: Icon(icon, size: 18.r, color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}
