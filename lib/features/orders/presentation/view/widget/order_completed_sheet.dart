import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';

/// شيت التهنئة بعد ما العميل يأكد الاستلام بالكود: علامة صح ورسالة شكر،
/// وزرار التقييم لو [canRate] (التقييم محتاج رقم المغسلة).
/// بيرجع true لو العميل عايز يقيّم، والشاشة هي اللي بتفتح شيت التقييم
class OrderCompletedSheet extends StatelessWidget {
  final bool canRate;

  const OrderCompletedSheet({super.key, required this.canRate});

  static Future<bool> show(
    BuildContext context, {
    required bool canRate,
  }) async {
    final wantsRating = await showOrderSheet<bool>(
      context,
      OrderCompletedSheet(canRate: canRate),
    );
    return wantsRating ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.greyColor5,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap(28.h),
              _buildCheck(),
              Gap(20.h),
              Text(
                'order_completed_title'.tr(),
                style: TextStyles.darkBold20,
                textAlign: TextAlign.center,
              ),
              Gap(10.h),
              Text(
                'order_completed_message'.tr(args: ['app_name'.tr()]),
                style: TextStyles.greyColor2Regular14.copyWith(height: 1.6),
                textAlign: TextAlign.center,
              ),
              Gap(28.h),
              if (canRate) ...[
                SheetButton(
                  label: 'rate_laundry'.tr(),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                Gap(10.h),
              ],
              SheetButton(
                label: 'close'.tr(),
                filled: !canRate,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// دايرة خضرا بعلامة صح بتكبر وهي بتظهر، وحواليها هالة فاتحة
  Widget _buildCheck() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: 96.r,
        height: 96.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.greenColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 68.r,
          height: 68.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.greenColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 40.r,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
