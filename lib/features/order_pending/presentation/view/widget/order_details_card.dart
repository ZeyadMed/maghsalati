import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';

/// كارت تفاصيل الطلب: كل قطعة وكميتها وسعرها وتحتهم الإجمالي
class OrderDetailsCard extends StatelessWidget {
  final PendingOrderModel order;

  /// شاشة القبول بتعرض الكارت من غير عنوان عشان يبقى مختصر
  final bool showTitle;

  const OrderDetailsCard({
    super.key,
    required this.order,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
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
          if (showTitle) ...[
            Text('order_details'.tr(), style: TextStyles.darkBold16),
            Gap(12.h),
          ],
          ...order.lines.map(_buildLine),
          if (order.deliveryPrice > 0) ...[
            _buildRow(
              'delivery_price'.tr(),
              '${_formatPrice(order.deliveryPrice)} ${'currency'.tr()}',
            ),
            Gap(10.h),
          ],
          Divider(height: 1.h, color: AppColors.lightGreyColor),
          Gap(10.h),
          _buildTotal(),
        ],
      ),
    );
  }

  /// "قميص" على جنب و "1 قطعة × 8 د.ل" على التاني
  Widget _buildLine(PendingOrderLine line) {
    final value =
        '${line.quantity} ${'piece'.tr()} × '
        '${_formatPrice(line.price)} ${'currency'.tr()}';
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: _buildRow(line.name, value),
    );
  }

  /// الاسم في بداية السطر (يمين في العربي) والقيمة في آخره
  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyles.darkBold14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(12.w),
        Text(
          value,
          style: TextStyles.greyColor2Regular14.copyWith(fontSize: 12.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'total'.tr(),
            style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(12.w),
        Text(
          '${_formatPrice(order.grandTotal)} ${'currency'.tr()}',
          style: TextStyles.blueBold20.copyWith(fontSize: 16.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// الرقم الصحيح بيتعرض من غير كسور يعني 8 مش 8.0
  String _formatPrice(num value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
}
