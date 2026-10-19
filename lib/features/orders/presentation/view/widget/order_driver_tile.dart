import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/phone_call.dart';

/// كارت المندوب المتعيّن على الرحلة زي الديزاين: أيقونة توصيل واسمه ورقمه
/// وزرار اتصال مدوّر بيفتح التليفون. لونه مختلف عن الكروت اللي تحته عشان يبان
class OrderDriverTile extends StatelessWidget {
  final OrderTripModel trip;

  const OrderDriverTile({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.delivery_dining_rounded,
              size: 26.r,
              color: AppColors.primaryColor,
            ),
          ),
          Gap(12.w),
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
                if (trip.driverName.isNotEmpty && trip.driverPhone.isNotEmpty)
                  Text(
                    trip.driverPhone,
                    style: TextStyles.darkRegular12.copyWith(
                      color: AppColors.greyColor3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trip.driverPhone.isNotEmpty) ...[
            Gap(8.w),
            _buildCallButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => callPhone(context, trip.driverPhone),
        child: SizedBox.square(
          dimension: 42.r,
          child: Icon(
            Icons.call_rounded,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
