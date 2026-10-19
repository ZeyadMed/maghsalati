import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_invoice.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// كارت طريقة الدفع: الطريقة، وحالة الدفع من أول ما يتطلب (بعد المطابقة)،
/// وزرار الدفع لو لسه مادفعش. قبل المطابقة بيقول إن الدفع بعد المراجعة.
/// حالة الطلب مش مستنية الدفع، فده تذكير مش شرط
class OrderPaymentCard extends StatelessWidget {
  final OrderModel order;

  /// لينك الدفع بيتجهز (إعادة الدفع ممكن تاخد وقت)
  final bool isLoading;
  final VoidCallback onPay;

  const OrderPaymentCard({
    super.key,
    required this.order,
    required this.isLoading,
    required this.onPay,
  });

  /// المرفوض والملغي من غير أي دفع مالهمش طريقة دفع يتعرضوا بيها
  static bool isShownFor(OrderModel order) =>
      order.isCurrent ||
      order.status.isPaymentPhase ||
      order.paymentStatus != PaymentStatus.none;

  @override
  Widget build(BuildContext context) {
    final failed = order.paymentStatus == PaymentStatus.failed;
    final methodKey = OrderInvoice.paymentMethodKeyOf(order.paymentMethod);
    final showStatus =
        order.status.isPaymentPhase ||
        order.paymentStatus != PaymentStatus.none;

    return OrderSectionCard(
      title: 'payment_method'.tr(),
      trailing: showStatus
          ? _PaymentStatusBadge(status: order.paymentStatus)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                methodKey == 'payment_method_cash'
                    ? Icons.payments_outlined
                    : Icons.credit_card_rounded,
                size: 22.r,
                color: AppColors.primaryColor,
              ),
              Gap(10.w),
              Expanded(
                child: Text(methodKey.tr(), style: TextStyles.darkBold14),
              ),
            ],
          ),
          if (order.needsPayment) ...[
            Gap(12.h),
            Text(
              failed ? 'payment_failed_message'.tr() : 'payment_note'.tr(),
              style: TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp),
            ),
            Gap(12.h),
            SheetButton(
              label:
                  '${(failed ? 'retry_payment' : 'pay_now').tr()} • '
                  '${formatOrderPrice(order.grandTotal)} ${'currency'.tr()}',
              isLoading: isLoading,
              onPressed: onPay,
            ),
          ] else if (!showStatus) ...[
            Gap(12.h),
            Text(
              'payment_after_match_note'.tr(),
              style: TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp),
            ),
          ],
        ],
      ),
    );
  }
}

/// شارة حالة الدفع، ولو السيرفر مابعتش الحالة وهو في مرحلة الدفع بتبان مستنية
class _PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const _PaymentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final shown = status == PaymentStatus.none ? PaymentStatus.pending : status;
    final color = switch (shown) {
      PaymentStatus.successful => AppColors.greenColor,
      PaymentStatus.failed => AppColors.redColor2,
      _ => AppColors.orangeColor,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        shown.labelKey.tr(),
        style: TextStyles.darkBold12.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
