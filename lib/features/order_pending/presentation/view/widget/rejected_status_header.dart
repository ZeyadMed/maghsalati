import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الجزء اللي فوق في شاشة رفض الطلب: علامة الإكس الحمرا
/// وتحتها عنوان الرفض وسطر بيقول إن المغسلة مش قادرة تستقبل الطلب
class RejectedStatusHeader extends StatelessWidget {
  final String laundryName;

  const RejectedStatusHeader({super.key, required this.laundryName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildIcon(),
        Gap(20.h),
        Text(
          'order_rejected_title'.tr(),
          style: TextStyles.darkBold20.copyWith(
            fontSize: 22.sp,
            color: AppColors.redColor2,
          ),
          textAlign: TextAlign.center,
        ),
        Gap(8.h),
        _buildRejectedNote(),
      ],
    );
  }

  /// دايرة حمرا فاتحة جواها علامة إكس
  Widget _buildIcon() {
    return Container(
      width: 80.r,
      height: 80.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.redColor2.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.close, size: 40.r, color: AppColors.darkTextColor),
    );
  }

  /// "عذراً، مغسلة النخبة غير قادرة على استقبال طلبك الآن"
  /// متقسمة لجزئين عشان اسم المغسلة يتحط في النص بأي لغة
  Widget _buildRejectedNote() {
    return Text(
      '${'order_rejected_prefix'.tr()} $laundryName '
      '${'order_rejected_suffix'.tr()}',
      style: TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp),
      textAlign: TextAlign.center,
    );
  }
}
