import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_price.dart';

/// فوتر السلة: إجمالي القطع ورسوم الاستلام والتسليم والإجمالي من السيرفر،
/// وتحتهم زرار تأكيد الطلب
class CartSummary extends StatelessWidget {
  final CartModel cart;
  final VoidCallback onConfirm;

  const CartSummary({super.key, required this.cart, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow('items_total'.tr(), cart.itemsTotal),
            if (cart.pickupFee > 0) ...[
              SizedBox(height: 6.h),
              _buildRow('pickup_fee'.tr(), cart.pickupFee),
            ],
            if (cart.dropoffFee > 0) ...[
              SizedBox(height: 6.h),
              _buildRow('dropoff_fee'.tr(), cart.dropoffFee),
            ],
            SizedBox(height: 8.h),
            Divider(height: 1, color: AppColors.borderColor),
            SizedBox(height: 8.h),
            _buildRow('total'.tr(), cart.totalPrice, emphasized: true),
            SizedBox(height: 12.h),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, num value, {bool emphasized = false}) {
    final style = emphasized
        ? TextStyles.darkBold16
        : TextStyles.greyColor2Regular14;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text('${formatCartPrice(value)} ${'currency'.tr()}', style: style),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text('confirm_order'.tr(), style: TextStyles.whiteBold15),
      ),
    );
  }
}
