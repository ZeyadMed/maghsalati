import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_items_chips.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_badge.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// كارت الطلب في تاب السابقة: من غير شريط خطوات لأن الطلب خلص
/// بيعرض رقم الطلب وعدد القطع والإجمالي وزرار عرض التفاصيل
class PreviousOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDetailsTap;

  const PreviousOrderCard({
    super.key,
    required this.order,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Gap(14.h),
          Text(
            '${order.totalPieces} ${'piece'.tr()}',
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.greyColor3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Gap(8.h),
          Divider(height: 1.h, color: AppColors.lightGreyColor),
          Gap(10.h),
          _buildFooter(),
        ],
      ),
    );
  }

  /// اسم المغسلة والتاريخ ورقم الطلب على جنب والشارة على التاني
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.laundryName,
                style: TextStyles.darkBold16.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(4.h),
              Text(
                DateFormat(
                  'd MMMM yyyy',
                  context.locale.toString(),
                ).format(order.date),
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(2.h),
              Text(
                '${'order_number'.tr()}: ${order.reference}',
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Gap(12.w),
        OrderStatusBadge(status: order.status),
      ],
    );
  }

  /// عدد القطع على جنب والإجمالي على التاني
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${formatOrderPrice(order.grandTotal)} ${'currency'.tr()}',
            style: TextStyles.blueBold20.copyWith(fontSize: 16.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(12.w),
        _buildDetailsButton(),
      ],
    );
  }

  /// الزرار اللي بيفتح شاشة تفاصيل الطلب
  Widget _buildDetailsButton() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(
        onPressed: onDetailsTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'view_details'.tr(),
              style: TextStyles.blueRegular15.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(2.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.r,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
