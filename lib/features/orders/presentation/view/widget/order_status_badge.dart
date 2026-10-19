import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// الشارة الملونة اللي فوق الكارت باسم مرحلة الطلب ([OrderModel.statusLabelKey]).
/// بعض الأسماء طويلة، فعرضها محدود والباقي بيتقطع
class OrderStatusBadge extends StatelessWidget {
  final OrderModel order;

  const OrderStatusBadge({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final color = OrderStatusStyle.foregroundOf(order.status);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 170.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: OrderStatusStyle.backgroundOf(order.status),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          order.statusLabelKey.tr(),
          style: TextStyles.darkBold12.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
