import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_items_chips.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_progress_tracker.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_badge.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// كارت الطلب في تاب الحالية: الحالة + شريط الخطوات + القطع + الإجمالي
/// الكارت نفسه مش بيفتح حاجة، الدخول على التفاصيل من زرار "عرض التفاصيل" بس
class CurrentOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDetailsTap;

  const CurrentOrderCard({
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Gap(16.h),
          OrderProgressTracker(status: order.status),
          Gap(16.h),
          Divider(height: 1.h, color: AppColors.lightGreyColor),
          Gap(10.h),
          _buildFooter(),
        ],
      ),
    );
  }

  /// اسم المغسلة والتاريخ على جنب والشارة على التاني
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(4.h),
              Text(
                _formatDate(context),
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
                textAlign: TextAlign.start,
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

  /// "اليوم" قدام التاريخ لو الطلب اتعمل النهاردة، زي ما في التصميم
  String _formatDate(BuildContext context) {
    final locale = context.locale.toString();
    final formatted = DateFormat('d MMMM yyyy', locale).format(order.date);

    final now = DateTime.now();
    final isToday =
        order.date.year == now.year &&
        order.date.month == now.month &&
        order.date.day == now.day;

    return isToday ? '${'today'.tr()}، $formatted' : formatted;
  }

  /// موعد التسليم المتوقع على جنب والإجمالي على التاني
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${'total'.tr()} '
            '${formatOrderPrice(order.grandTotal)} ${'currency'.tr()}',
            style: TextStyles.blueBold20.copyWith(fontSize: 16.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
