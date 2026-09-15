import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// البار الثابت تحت الصفحة: الإجمالي على جنب وزرار تأكيد الطلب على التاني
/// بيسمع للـ controller فالسعر بيتغير مع كل قطعة تتزود أو تتشال
class OrderSummaryBar extends StatelessWidget {
  final SelectedServicesController controller;
  final VoidCallback? onConfirm;

  const OrderSummaryBar({super.key, required this.controller, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final enabled = controller.hasSelection;
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
                Expanded(child: _buildTotals()),
                SizedBox(width: 12.w),
                _buildConfirmButton(enabled),
              ],
            ),
          ),
        );
      },
    );
  }

  /// سطر القطع والتوصيل وتحته الإجمالي
  Widget _buildTotals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _breakdownLabel(),
          style: TextStyles.greyColor2Regular14.copyWith(fontSize: 11.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
        ),
        SizedBox(height: 2.h),
        Text(
          '${_formatPrice(controller.grandTotal)} ${'currency'.tr()}',
          style: TextStyles.darkBold18.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildConfirmButton(bool enabled) {
    return ElevatedButton(
      onPressed: enabled ? onConfirm : null,
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
  String _breakdownLabel() {
    final pieces = '${controller.totalPieces} ${'piece'.tr()}';
    if (controller.deliveryPrice <= 0) return pieces;
    final delivery =
        '${'delivery_price'.tr()} ${_formatPrice(controller.deliveryPrice)} '
        '${'currency'.tr()}';
    return '$pieces • $delivery';
  }

  /// الرقم الصحيح بيتعرض من غير كسور يعني 8 مش 8.0
  String _formatPrice(num value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
}
