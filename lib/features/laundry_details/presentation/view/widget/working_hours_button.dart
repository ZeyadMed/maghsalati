import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/home/presentation/view/widget/working_hours_dialog.dart';

/// كارت "عرض مواعيد العمل" في تفاصيل المغسلة، بيفتح ديالوج المواعيد
class WorkingHoursButton extends StatelessWidget {
  final int laundryId;
  final String laundryName;

  const WorkingHoursButton({
    super.key,
    required this.laundryId,
    required this.laundryName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => WorkingHoursDialog.show(
          context,
          laundryId: laundryId,
          laundryName: laundryName,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 20.r,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: LocalizedLabel(
                  text: 'show_working_hours',
                  style: TextStyles.darkBold14,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: AppColors.greyColor2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
