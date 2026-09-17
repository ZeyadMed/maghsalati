import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// البانر الأزرق اللي فوق الشيبس، فيه جملة دعائية وزرار صغير
/// النص بييجي من بره عشان يتغير من ال endpoint بعدين
class ServicesPromoBanner extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const ServicesPromoBanner({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      color: AppColors.lightBlueColor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyles.whiteText(14, weight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.lightOrangeColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'know_more'.tr(),
                style: TextStyles.boldStyle(11, color: AppColors.blackColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
