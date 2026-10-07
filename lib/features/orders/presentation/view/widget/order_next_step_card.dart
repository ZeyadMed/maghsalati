import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';

/// كارت "الخطوة الجاية" في تفاصيل الطلب: الطلب فين دلوقتي، ولو فيه حاجة
/// مطلوبة من العميل (يراجع تعديل، يأكد الاستلام، يقيّم، يختار مغسلة تانية)
/// بيظهر زرارها. الدفع ليه كارت لوحده لأنه ماشي جنب الحالة مش جزء منها
class OrderNextStepCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onReviewAdjustment;
  final VoidCallback onConfirmDropoff;
  final VoidCallback onRateLaundry;
  final VoidCallback onChooseAnotherLaundry;

  const OrderNextStepCard({
    super.key,
    required this.order,
    required this.onReviewAdjustment,
    required this.onConfirmDropoff,
    required this.onRateLaundry,
    required this.onChooseAnotherLaundry,
  });

  @override
  Widget build(BuildContext context) {
    final step = _stepOf(order);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        // الحالة اللي مستنية العميل ليها إطار بلونها عشان تلفت نظره
        border: step.needsAction
            ? Border.all(color: step.color.withValues(alpha: 0.5))
            : null,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(step),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.titleKey.tr(), style: TextStyles.darkBold16),
                    Gap(4.h),
                    Text(
                      step.body,
                      style: TextStyles.greyColor2Regular14.copyWith(
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (step.actionKey != null && step.onAction != null) ...[
            Gap(14.h),
            SheetButton(
              label: step.actionKey!.tr(),
              color: step.needsAction ? step.color : AppColors.primaryColor,
              onPressed: step.onAction,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(_NextStep step) {
    return Container(
      width: 44.r,
      height: 44.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(step.icon, size: 22.r, color: step.color),
    );
  }

  _NextStep _stepOf(OrderModel order) => switch (order.status) {
    OrderStatus.newOrder => _NextStep(
      icon: Icons.hourglass_top_rounded,
      color: AppColors.orangeColor,
      titleKey: 'next_step_new_title',
      body: 'order_pending_note'.tr(),
    ),
    OrderStatus.awaitingPickup => _NextStep(
      icon: Icons.local_shipping_outlined,
      color: AppColors.primaryColor,
      titleKey: 'next_step_awaiting_pickup_title',
      body: 'next_step_awaiting_pickup_body'.tr(),
    ),
    OrderStatus.atLaundryPendingMatch => _NextStep(
      icon: Icons.fact_check_outlined,
      color: AppColors.primaryColor,
      titleKey: 'next_step_pending_match_title',
      body: 'next_step_pending_match_body'.tr(),
    ),
    OrderStatus.adjustmentPendingApproval => _NextStep(
      icon: Icons.rule_rounded,
      color: AppColors.orangeColor,
      titleKey: 'next_step_adjustment_title',
      body: 'next_step_adjustment_body'.tr(),
      actionKey: 'review_adjustment',
      onAction: onReviewAdjustment,
      needsAction: true,
    ),
    OrderStatus.inProgress => _NextStep(
      icon: Icons.local_laundry_service_outlined,
      color: AppColors.primaryColor,
      titleKey: 'next_step_in_progress_title',
      body: 'next_step_in_progress_body'.tr(),
    ),
    OrderStatus.ready => _NextStep(
      icon: Icons.inventory_2_outlined,
      color: AppColors.greenColor,
      titleKey: 'next_step_ready_title',
      body: 'next_step_ready_body'.tr(),
    ),
    OrderStatus.awaitingDropoffCollection => _NextStep(
      icon: Icons.storefront_outlined,
      color: AppColors.primaryColor,
      titleKey: 'next_step_awaiting_dropoff_collection_title',
      body: 'next_step_awaiting_dropoff_collection_body'.tr(),
    ),
    // زرار الكود بيظهر بس لما الرحلة تقول إنها مستنية العميل
    // (awaitingConfirmationBy == Customer)، لأن رحلة التسليم ليها كود قبله
    // للمغسلة. ولو الريسبونس قديم من غير الحقل ده بيفضل ظاهر طول التوصيل
    OrderStatus.outForDelivery => _NextStep(
      icon: Icons.delivery_dining_outlined,
      color: AppColors.primaryColor,
      titleKey: (order.dropoffTrip?.hasArrived ?? false)
          ? 'next_step_driver_arrived_title'
          : 'next_step_out_for_delivery_title',
      body: 'next_step_out_for_delivery_body'.tr(),
      actionKey: (order.dropoffTrip?.awaitsCustomer ?? true)
          ? 'confirm_receipt'
          : null,
      onAction: onConfirmDropoff,
      needsAction: order.dropoffTrip?.awaitsCustomer ?? true,
    ),
    OrderStatus.delivered => _NextStep(
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.greenColor,
      titleKey: 'next_step_delivered_title',
      body: 'next_step_delivered_body'.tr(),
      // التقييم محتاج رقم المغسلة، فمن غيره الزرار مابيظهرش
      actionKey: order.laundryId > 0 ? 'rate_laundry' : null,
      onAction: onRateLaundry,
    ),
    OrderStatus.rejected => _NextStep(
      icon: Icons.cancel_outlined,
      color: AppColors.redColor2,
      titleKey: 'next_step_rejected_title',
      body: order.rejectionReason.isNotEmpty
          ? '${'rejection_reason'.tr()}: ${order.rejectionReason}'
          : 'next_step_rejected_body'.tr(),
      actionKey: 'choose_another_laundry',
      onAction: onChooseAnotherLaundry,
    ),
    // الفشل مش مطلوب فيه حاجة من العميل، المغسلة هي اللي بتقرر الخطوة الجاية
    OrderStatus.pickupFailed => _NextStep(
      icon: Icons.error_outline_rounded,
      color: AppColors.redColor2,
      titleKey: 'next_step_pickup_failed_title',
      body: 'next_step_pickup_failed_body'.tr(),
    ),
    OrderStatus.deliveryFailed => _NextStep(
      icon: Icons.error_outline_rounded,
      color: AppColors.redColor2,
      titleKey: 'next_step_delivery_failed_title',
      body: 'next_step_delivery_failed_body'.tr(),
    ),
    OrderStatus.cancelled => _NextStep(
      icon: Icons.block_rounded,
      color: AppColors.greyColor3,
      titleKey: 'next_step_cancelled_title',
      body: 'next_step_cancelled_body'.tr(),
      actionKey: 'choose_another_laundry',
      onAction: onChooseAnotherLaundry,
    ),
  };
}

/// شكل الكارت لكل حالة
class _NextStep {
  final IconData icon;
  final Color color;
  final String titleKey;

  /// نص جاهز مش مفتاح، عشان سبب الرفض بييجي من السيرفر
  final String body;
  final String? actionKey;
  final VoidCallback? onAction;

  /// الطلب واقف على رد العميل
  final bool needsAction;

  const _NextStep({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.body,
    this.actionKey,
    this.onAction,
    this.needsAction = false,
  });
}
