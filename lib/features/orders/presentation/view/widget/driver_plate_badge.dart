import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// لوحة مركبة المندوب شكلها زي اللوحة الحقيقية: أبيض بإطار غامق وخط عريض،
/// ودايمًا من الشمال لليمين عشان الأرقام ماتتقلبش في العربي
class DriverPlateBadge extends StatelessWidget {
  final String plateNumber;

  const DriverPlateBadge({super.key, required this.plateNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.blackColor, width: 1.5),
      ),
      child: Text(
        plateNumber,
        textDirection: ui.TextDirection.ltr,
        style: TextStyles.darkBold14.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}
