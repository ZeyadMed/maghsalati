import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';

/// كارت المغسلة: لوجوها واسمها، ولو اللوجو مش موجود بتبان أيقونة محل
class OrderLaundryCard extends StatelessWidget {
  final OrderModel order;

  const OrderLaundryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return OrderSectionCard(
      child: Row(
        children: [
          _buildLogo(),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ordered_from'.tr(),
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor3,
                  ),
                ),
                Gap(2.h),
                Text(
                  order.laundryName,
                  style: TextStyles.darkBold16,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final size = 54.r;

    if (order.laundryLogo.isEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(
          Icons.storefront_rounded,
          size: 28.r,
          color: AppColors.primaryColor,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: FlexibleImage(
          source: order.laundryLogo,
          width: size,
          height: size,
          borderRadius: 14,
        ),
      ),
    );
  }
}
