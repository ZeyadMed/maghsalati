import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// كارت الدفع: بيبان من أول ما الدفع يتطلب (بعد المطابقة)، وفيه حالة الدفع
/// وزرار الدفع لو لسه مادفعش. حالة الطلب مش مستنية الدفع، فده تذكير مش شرط
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

  @override
  Widget build(BuildContext context) {
    final failed = order.paymentStatus == PaymentStatus.failed;

    return Container(
      padding: EdgeInsets.all(16.r),
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
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 22.r,
                color: AppColors.primaryColor,
              ),
              Gap(10.w),
              Expanded(
                child: Text('payment'.tr(), style: TextStyles.darkBold16),
              ),
              _PaymentStatusBadge(status: order.paymentStatus),
            ],
          ),
          if (!order.isPaid) ...[
            Gap(10.h),
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
