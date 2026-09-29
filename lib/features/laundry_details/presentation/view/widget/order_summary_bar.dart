import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';

/// البار الثابت تحت الصفحة: الإجمالي على جنب وزرار تأكيد الطلب على التاني
/// بيقرا من سلة السيرفر مش من الكاونتر، فالسعر مابيتغيرش مع + و -
/// وبيتحدث بس لما "أضف للسلة" ينجح والسلة تتجاب تاني
class OrderSummaryBar extends StatelessWidget {
  final CartCubit cartCubit;

  /// المغسلة اللي الشاشة فاتحاها، ولو السلة بتاعة مغسلة تانية البار بيبان فاضي
  final int laundryId;
  final ValueChanged<CartModel>? onConfirm;

  const OrderSummaryBar({
    super.key,
    required this.cartCubit,
    required this.laundryId,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, BaseState<CartModel>>(
      bloc: cartCubit,
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        final data = state.data;
        final cart = data != null && data.laundryId == laundryId ? data : null;
        final enabled = cart != null && !cart.isEmpty;
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          // SafeArea تحت بس عشان الزرار مايتحطش على شريط النظام
          child: SafeArea(
            top: false,
            child: Row(
              // الزرار في بداية السطر (شمال في العربي) والسعر في آخره
              // فبنعكس اتجاه الصف عن اتجاه اللغة
              // textDirection: ui.TextDirection.ltr,
              children: [
                Expanded(child: _buildTotals(enabled ? cart : null)),
                SizedBox(width: 12.w),
                _buildConfirmButton(enabled ? cart : null),
              ],
            ),
          ),
        );
      },
    );
  }

  /// سطر القطع والتوصيل وتحته الإجمالي
  Widget _buildTotals(CartModel? cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _breakdownLabel(cart),
          style: TextStyles.greyColor2Regular14.copyWith(fontSize: 11.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
        ),
        SizedBox(height: 2.h),
        Text(
          '${_formatPrice(cart?.totalPrice ?? 0)} ${'currency'.tr()}',
          style: TextStyles.darkBold18.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// من غير سلة للمغسلة دي الزرار بيتقفل
  Widget _buildConfirmButton(CartModel? cart) {
    final onConfirm = this.onConfirm;
    return ElevatedButton(
      onPressed: cart == null || onConfirm == null
          ? null
          : () => onConfirm(cart),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: AppColors.greyColor5,
        foregroundColor: AppColors.whiteColor,
        disabledForegroundColor: AppColors.whiteColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('confirm_order'.tr(), style: TextStyles.whiteBold14),
          SizedBox(width: 6.w),
          // بيلف لوحده حسب اتجاه اللغة (يسار في العربي ويمين في الإنجليزي)
          Icon(
            Icons.arrow_forward,
            size: 16.r,
            color: AppColors.whiteColor,
            textDirection: ui.TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  /// "4 قطعة • توصيل 8 د.ل"
  /// التوصيل = رسوم الاستلام + التسليم جايين من السيرفر
  String _breakdownLabel(CartModel? cart) {
    final pieces = '${cart?.totalPieces ?? 0} ${'piece'.tr()}';
    final deliveryFees = cart?.deliveryFees ?? 0;
    if (deliveryFees <= 0) return pieces;
    final delivery =
        '${'delivery_price'.tr()} ${_formatPrice(deliveryFees)} '
        '${'currency'.tr()}';
    return '$pieces • $delivery';
  }

  /// الرقم الصحيح بيتعرض من غير كسور يعني 8 مش 8.0
  String _formatPrice(num value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
}
