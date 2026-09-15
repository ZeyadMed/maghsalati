import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الجزء اللي فوق في شاشة قبول الطلب: علامة الصح الخضرا
/// وتحتها عنوان القبول واسم المغسلة ومواعيد الاستلام والتسليم
class AcceptedStatusHeader extends StatelessWidget {
  final String laundryName;

  const AcceptedStatusHeader({super.key, required this.laundryName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildIcon(),
        Gap(24.h),
        Text(
          'order_accepted_title'.tr(),
          style: TextStyles.darkBold20.copyWith(
            fontSize: 22.sp,
            color: AppColors.greenColor,
          ),
          textAlign: TextAlign.center,
        ),
        Gap(8.h),
        _buildAcceptedByLaundry(),
        Gap(4.h),
        _buildTiming(),
      ],
    );
  }

  /// دايرة خضرا فاتحة جواها علامة صح
  Widget _buildIcon() {
    return Container(
      width: 80.r,
      height: 80.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.greenColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, size: 44.r, color: AppColors.greenColor),
    );
  }

  /// "مغسلة النخبة قبلت طلبك" واسم المغسلة بيبان عادي في أول الجملة
  Widget _buildAcceptedByLaundry() {
    return Text(
      '$laundryName ${'order_accepted_by'.tr()}',
      style: TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp),
      textAlign: TextAlign.center,
    );
  }

  /// "استلام: اليوم • تسليم: غداً" والقيم بخط تقيل
  Widget _buildTiming() {
    final labelStyle = TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp);
    final valueStyle = TextStyles.darkBold14.copyWith(fontSize: 13.sp);

    return Text.rich(
      TextSpan(
        style: labelStyle,
        children: [
          TextSpan(text: '${'pickup_label'.tr()}: '),
          TextSpan(text: 'today'.tr(), style: valueStyle),
          const TextSpan(text: ' • '),
          TextSpan(text: '${'delivery_label'.tr()}: '),
          TextSpan(text: 'tomorrow'.tr(), style: valueStyle),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
