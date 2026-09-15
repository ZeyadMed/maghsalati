import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// البادج اللي بتبان جنب القسم الرئيسي وفيها عدد القطع المختارة (مش عدد الخدمات)
class PiecesCountBadge extends StatelessWidget {
  final int count;

  const PiecesCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '$count ${'piece'.tr()}',
        style: TextStyles.whiteText(11, weight: FontWeight.w500),
      ),
    );
  }
}
