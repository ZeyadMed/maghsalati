import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/home/presentation/view/widget/timing_box.dart';

/// بوكسات الاستلام والتسليم جنب بعض، وبوكس تالت لسعر التوصيل لو مفعّل
class TimingRow extends StatelessWidget {
  final String pickUpTime;
  final String deliveryTime;

  /// لو true بيظهر بوكس تالت بسعر التوصيل، ولازم [deliveryPrice] يتبعت معاه
  final bool showDeliveryPrice;
  final num? deliveryPrice;

  const TimingRow({
    super.key,
    required this.pickUpTime,
    required this.deliveryTime,
    this.showDeliveryPrice = false,
    this.deliveryPrice,
  }) : assert(
         !showDeliveryPrice || deliveryPrice != null,
         'deliveryPrice is required when showDeliveryPrice is true',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TimingBox(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primaryColor,
            title: 'pick_up'.tr(),
            value: pickUpTime,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: TimingBox(
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.redColor2,
            title: 'delivery'.tr(),
            value: deliveryTime,
          ),
        ),
        if (showDeliveryPrice) ...[
          SizedBox(width: 10.w),
          Expanded(
            child: TimingBox(
              icon: Icons.payments_outlined,
              iconColor: AppColors.greenColor,
              title: 'delivery_price'.tr(),
              value: '$deliveryPrice ${'currency'.tr()}',
            ),
          ),
        ],
      ],
    );
  }
}
