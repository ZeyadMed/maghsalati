import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/quantity_counter.dart';

/// صف القطعة الفرعية (قميص - بنطلون ...) وتحته السعر
/// وهي مش مختارة بيبان زرار + ، ولما تتختار بيتحول لـ ✓ ويفتح الكاونتر
class ServiceItemTile extends StatelessWidget {
  final ServiceItemModel item;
  final int quantity;
  final VoidCallback onSelect;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ServiceItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onSelect,
    required this.onIncrement,
    required this.onDecrement,
  });

  bool get _isSelected => quantity > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _isSelected ? AppColors.fillColor : AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isSelected ? AppColors.primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      // الاسم والسعر في بداية السطر (يمين في العربي) والزراير بعدهم على الشمال
      child: Row(
        children: [
          Expanded(
            child: Column(
              // start بيبقى يمين في العربي وشمال في الإنجليزي لوحده
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: TextStyles.darkBold14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  _priceLabel(),
                  style: TextStyles.greyColor2Regular14.copyWith(
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _buildAction(),
        ],
      ),
    );
  }

  /// السعر + العملة + وحدة التسعير الجاية من السيرفر
  /// الرقم الصحيح بيتعرض من غير كسور يعني 3 مش 3.0
  String _priceLabel() {
    final value = item.price % 1 == 0
        ? item.price.toInt().toString()
        : item.price.toString();
    final price = '$value ${'currency'.tr()}';
    return item.unit.isEmpty ? price : '$price / ${item.unit}';
  }

  /// مش مختارة يبقى زرار + ، ولما تتختار الكاونتر بس من غير أي علامة
  Widget _buildAction() {
    if (!_isSelected) {
      return InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 30.r,
          height: 30.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.add, size: 18.r, color: AppColors.primaryColor),
        ),
      );
    }

    return QuantityCounter(
      quantity: quantity,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
    );
  }
}
