import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// دايرة حمرا فيها رقم: على القطعة بعدد اللي اتختار منها،
/// وعلى أيقونة السلة بعدد القطع كلها
class CountBadge extends StatelessWidget {
  final int count;

  const CountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 20.r),
      height: 20.r,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: AppColors.redColor2,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.whiteColor, width: 1.5),
      ),
      child: Text(
        '$count',
        style: TextStyles.whiteText(11, weight: FontWeight.bold),
      ),
    );
  }
}
