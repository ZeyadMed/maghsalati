import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// زرار "ادفع الآن" أو "ادفع الفرق" بالمبلغ المستحق في كروت ليستة الطلبات.
/// بيظهر بس لو [OrderModel.needsPayment]، والدوسة بتفتح التفاصيل وشيت الدفع
class OrderPayButton extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onPressed;

  const OrderPayButton({
    super.key,
    required this.order,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.payments_outlined,
          size: 18.r,
          color: AppColors.whiteColor,
        ),
        label: Text(
          '${order.payActionKey.tr()} • '
          '${formatOrderPrice(order.amountDue)} ${'currency'.tr()}',
          style: TextStyles.whiteBold14,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangeColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

/// المسافة والزرار تحت محتوى الكارت، ولا حاجة لو مفيش مستحق
List<Widget> orderPaySection(OrderModel order, VoidCallback? onPay) => [
  if (order.needsPayment && onPay != null) ...[
    Gap(10.h),
    OrderPayButton(order: order, onPressed: onPay),
  ],
];
