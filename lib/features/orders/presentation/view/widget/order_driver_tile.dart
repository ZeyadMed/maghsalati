import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/common_widget/custom_error_message.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// المندوب المتعيّن على الرحلة: اسمه وزرار اتصال بيفتح التليفون
class OrderDriverTile extends StatelessWidget {
  final OrderTripModel trip;

  const OrderDriverTile({super.key, required this.trip});

  /// لو الجهاز مش عارف يفتح الاتصال بنعرض رسالة بدل ما الدوسة تضيع
  Future<void> _call(BuildContext context) async {
    final launched = await launchUrl(
      Uri.parse('tel:${trip.driverPhone}'),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);

    if (!launched && context.mounted) {
      CustomErrorOverlay.show(context: context, text: 'contact_failed'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.whiteColor,
            child: Icon(
              Icons.person_outline_rounded,
              size: 20.r,
              color: AppColors.primaryColor,
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'driver'.tr(),
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor3,
                  ),
                ),
                Gap(2.h),
                Text(
                  trip.driverName.isNotEmpty
                      ? trip.driverName
                      : trip.driverPhone,
                  style: TextStyles.darkBold14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trip.driverPhone.isNotEmpty)
            IconButton(
              onPressed: () => _call(context),
              icon: Icon(
                Icons.call_rounded,
                size: 22.r,
                color: AppColors.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
