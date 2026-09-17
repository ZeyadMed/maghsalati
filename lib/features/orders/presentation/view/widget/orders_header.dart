import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الهيدر الأزرق بعنوان الشاشة، بنفس شكل هيدر الرئيسية
class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        bottom: 20.h,
        start: 20.w,
        end: 20.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(28.r),
          bottomEnd: Radius.circular(28.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'my_orders'.tr(),
            style: TextStyles.whiteText(20, weight: FontWeight.w700),
          ),
          Gap(4.h),
          Text(
            'orders_subtitle'.tr(),
            style: TextStyles.whiteText(
              12,
              weight: FontWeight.w300,
            ).copyWith(color: AppColors.whiteColor.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}
