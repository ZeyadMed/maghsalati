import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الجزء اللي فوق: أيقونة السلة وتحتها عنوان الانتظار
/// واسم المغسلة بيبان بلون البراند جوا الجملة
class PendingStatusHeader extends StatelessWidget {
  final String laundryName;

  const PendingStatusHeader({super.key, required this.laundryName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildIcon(),
        Gap(24.h),
        Text(
          'order_pending_title'.tr(),
          style: TextStyles.darkBold20.copyWith(fontSize: 22.sp),
          textAlign: TextAlign.center,
        ),
        Gap(8.h),
        _buildSentToLaundry(),
        Gap(4.h),
        Text(
          'order_pending_note'.tr(),
          style: TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// دايرة فاتحة جواها أيقونة السلة
  Widget _buildIcon() {
    return Container(
      width: 96.r,
      height: 96.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shopping_basket_outlined,
        size: 48.r,
        color: AppColors.primaryColor,
      ),
    );
  }

  /// "تم إرسال طلبك إلى مغسلة النخبة" واسم المغسلة بلون البراند
  Widget _buildSentToLaundry() {
    return Text.rich(
      TextSpan(
        style: TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp),
        children: [
          TextSpan(text: '${'order_sent_to'.tr()} '),
          TextSpan(
            text: laundryName,
            style: TextStyles.darkBold14.copyWith(
              color: AppColors.primaryColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
