import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// كارت أبيض فيه عنوان وفقرة، بتستخدمه شاشات سياسة الخصوصية وعن التطبيق
/// نفس شكل كروت الطلبات عشان الشاشات كلها تبقى متسقة
class InfoSectionCard extends StatelessWidget {
  /// مفتاح ترجمة العنوان
  final String titleKey;

  /// مفتاح ترجمة الفقرة، بيتعرض تحت العنوان
  final String bodyKey;

  /// أيقونة العنوان، جوا مربع ملون زي سطور القايمة
  final IconData icon;
  final Color iconColor;

  const InfoSectionCard({
    super.key,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    this.iconColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18.r, color: iconColor),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  titleKey.tr(),
                  style: TextStyles.darkBold16.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            bodyKey.tr(),
            style: TextStyles.darkRegular14.copyWith(
              color: AppColors.greyColor2,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
