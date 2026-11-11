import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// كارت "الخطوة الجاية" في تفاصيل الطلب: الطلب فين دلوقتي، ولو فيه حاجة
/// مطلوبة من العميل (يدفع، يراجع تعديل، يقيّم، يختار مغسلة تانية)
/// بيظهر زرارها. أي مبلغ مستحق بيتقدم على أي حاجة تانية، لأن الطلب مش بيوصل
/// المغسلة قبل الدفع المبدئي، والمغسلة مش بتجهّزه قبل دفع الفرق
class OrderNextStepCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onPay;
  final VoidCallback onReviewAdjustment;
  final VoidCallback onRateLaundry;
  final VoidCallback onChooseAnotherLaundry;

  const OrderNextStepCard({
    super.key,
    required this.order,
    required this.onPay,
    required this.onReviewAdjustment,
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
          if (step.actionLabel != null && step.onAction != null) ...[
            Gap(14.h),
            SheetButton(
              label: step.actionLabel!,
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

  _NextStep _stepOf(OrderModel order) {
    if (order.needsPayment) return _paymentStepOf(order);
    return _statusStepOf(order);
  }

  /// فيه مبلغ مستحق: الدفع المبدئي (الطلب لسه ماوصلش المغسلة)
  /// أو فرق المطابقة (المغسلة مستنياه عشان تجهّز)
  _NextStep _paymentStepOf(OrderModel order) {
    final amount = '${formatOrderPrice(order.amountDue)} ${'currency'.tr()}';
    final (titleKey, bodyKey) = switch (order) {
      _ when order.status == OrderStatus.pendingPayment => (
        'next_step_pending_payment_title',
        'next_step_pending_payment_body',
      ),
      _ when order.isDifferenceDue => (
        'next_step_difference_due_title',
        'next_step_difference_due_body',
      ),
      _ => ('next_step_payment_due_title', 'next_step_payment_due_body'),
    };
    return _NextStep(
      icon: Icons.payments_outlined,
      color: order.paymentStatus == PaymentStatus.failed
          ? AppColors.redColor2
          : AppColors.orangeColor,
      titleKey: titleKey,
      body: order.paymentStatus == PaymentStatus.failed
          ? 'payment_failed_message'.tr()
          : bodyKey.tr(),
      actionLabel: '${order.payActionKey.tr()} • $amount',
      onAction: onPay,
      needsAction: true,
    );
  }

  _NextStep _statusStepOf(OrderModel order) => switch (order.status) {
    // اتدفع والنتيجة لسه بتوصل (المستحق 0 والحالة لسه ماتغيرتش)
    OrderStatus.pendingPayment => _NextStep(
      icon: Icons.schedule_rounded,
      color: AppColors.orangeColor,
      titleKey: 'status_pending_payment',
      body: 'payment_processing'.tr(),
    ),
    OrderStatus.newOrder => _NextStep(
      icon: Icons.hourglass_top_rounded,
      color: AppColors.orangeColor,
      titleKey: 'next_step_new_title',
      body: 'order_pending_note'.tr(),
    ),
    // العميل ممكن يودّي الهدوم المغسلة بنفسه بدل المندوب ([OrderModel.customerDropsOff])
    OrderStatus.awaitingPickup when order.customerDropsOff => _NextStep(
      icon: Icons.storefront_outlined,
      color: AppColors.primaryColor,
      titleKey: 'next_step_awaiting_dropoff_title',
      body: 'next_step_awaiting_dropoff_body'.tr(),
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
      actionLabel: 'review_adjustment'.tr(),
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
      // العميل هيستلم من المغسلة بنفسه ([OrderModel.customerCollects])
      body:
          (order.customerCollects
                  ? 'next_step_ready_pickup_body'
                  : 'next_step_ready_body')
              .tr(),
    ),
    OrderStatus.awaitingDropoffCollection => _NextStep(
      icon: Icons.storefront_outlined,
      color: AppColors.primaryColor,
      titleKey: 'next_step_awaiting_dropoff_collection_title',
      body: 'next_step_awaiting_dropoff_collection_body'.tr(),
    ),
    // مفيش كود: المندوب هو اللي بيأكد التسليم. لما يوصل الكارت بيتعلّم
    // عشان العميل يطلع ياخد هدومه
    OrderStatus.outForDelivery => _NextStep(
      icon: Icons.delivery_dining_outlined,
      color: AppColors.primaryColor,
      titleKey: order.isDriverAtDoor
          ? 'next_step_driver_arrived_title'
          : 'next_step_out_for_delivery_title',
      body:
          (order.isDriverAtDoor
                  ? 'next_step_driver_arrived_body'
                  : 'next_step_out_for_delivery_body')
              .tr(),
      needsAction: order.isDriverAtDoor,
    ),
    OrderStatus.delivered => _NextStep(
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.greenColor,
      titleKey: 'next_step_delivered_title',
      // نفس رسالة الشكر اللي بتظهر في شيت التهنئة بعد التسليم
      body: 'order_completed_message'.tr(args: ['app_name'.tr()]),
      // التقييم محتاج رقم المغسلة، فمن غيره الزرار مابيظهرش
      actionLabel: order.laundryId > 0 ? 'rate_laundry'.tr() : null,
      onAction: onRateLaundry,
    ),
    OrderStatus.rejected => _NextStep(
      icon: Icons.cancel_outlined,
      color: AppColors.redColor2,
      titleKey: 'next_step_rejected_title',
      body: order.rejectionReason.isNotEmpty
          ? '${'rejection_reason'.tr()}: ${order.rejectionReason}'
          : 'next_step_rejected_body'.tr(),
      actionLabel: 'choose_another_laundry'.tr(),
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
      actionLabel: 'choose_another_laundry'.tr(),
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

  /// نص الزرار جاهز، عشان زرار الدفع فيه المبلغ
  final String? actionLabel;
  final VoidCallback? onAction;

  /// الطلب واقف على رد العميل
  final bool needsAction;

  const _NextStep({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.needsAction = false,
  });
}
