import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// كارت الدفع: الطريقة اللي اتختارت وقت الطلب (محفظة أو بوابة)، واللي اتدفع،
/// والمستحق لو فيه. زرار الدفع نفسه في كارت الخطوة الجاية فوق، لأن الدفع
/// بقى بيوقف الطلب (مش بيوصل المغسلة قبله، ومش بيتجهز قبل دفع الفرق)
class OrderPaymentCard extends StatelessWidget {
  final OrderModel order;

  const OrderPaymentCard({super.key, required this.order});

  /// المرفوض والملغي من غير أي دفع مالهمش حاجة تتعرض
  static bool isShownFor(OrderModel order) =>
      order.isCurrent ||
      order.isPaid ||
      order.needsPayment ||
      (order.amountPaid ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final method = order.paymentMethod ?? PaymentMethod.gateway;
    final paid = order.amountPaid ?? (order.isPaid ? order.grandTotal : 0);

    return OrderSectionCard(
      title: 'payment_method'.tr(),
      trailing: _PaymentStatusBadge(
        status: order.isPaid
            ? PaymentStatus.successful
            : order.paymentStatus == PaymentStatus.failed
            ? PaymentStatus.failed
            : PaymentStatus.pending,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(method.icon, size: 22.r, color: AppColors.primaryColor),
              Gap(10.w),
              Expanded(
                child: Text(method.labelKey.tr(), style: TextStyles.darkBold14),
              ),
            ],
          ),
          if (paid > 0) ...[
            Gap(12.h),
            _buildAmountRow('invoice_paid_amount'.tr(), paid),
          ],
          if (order.needsPayment) ...[
            Gap(8.h),
            _buildAmountRow(
              'amount_due'.tr(),
              order.amountDue,
              color: AppColors.orangeColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, num amount, {Color? color}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyles.darkRegular14.copyWith(
              color: AppColors.greyColor2,
            ),
          ),
        ),
        Text(
          '${formatOrderPrice(amount)} ${'currency'.tr()}',
          style: TextStyles.darkBold14.copyWith(color: color),
        ),
      ],
    );
  }
}

/// شارة حالة الدفع: تم الدفع، أو بانتظار الدفع، أو فشل الدفع
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
