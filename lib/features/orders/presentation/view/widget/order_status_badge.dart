import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// الشارة الملونة اللي فوق الكارت (قيد الغسيل - مكتمل - ملغي ...)
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = OrderStatusStyle.foregroundOf(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: OrderStatusStyle.backgroundOf(status),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.labelKey.tr(),
        style: TextStyles.darkBold12.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
