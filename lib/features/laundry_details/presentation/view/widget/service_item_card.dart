import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/quantity_counter.dart';

/// كارت القطعة في الجريد: صورة فوق وتحتها الاسم والسعر وزرار الإضافة
/// وهي مش مختارة بيبان زرار + ، ولما تتختار بيتحول لكاونتر بالكمية
class ServiceItemCard extends StatelessWidget {
  final ServiceItemModel item;
  final int quantity;
  final VoidCallback onSelect;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ServiceItemCard({
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
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _isSelected ? AppColors.primaryColor : AppColors.borderColor,
          width: _isSelected ? 1.5 : 1,
        ),
      ),
      padding: EdgeInsets.all(8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildImage()),
          SizedBox(height: 6.h),
          Text(
            item.name,
            style: TextStyles.darkBold14.copyWith(fontSize: 12.sp),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            _priceLabel(),
            style: TextStyles.orangeBold12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          _buildAction(),
        ],
      ),
    );
  }

  /// الصورة ممكن تكون لينك أو إيموجي جاي من السيرفر، فبنفرق بينهم هنا
  Widget _buildImage() {
    final isEmoji = !item.image.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: double.infinity,
        child: isEmoji
            ? Container(
                color: AppColors.secondaryColor,
                alignment: Alignment.center,
                child: Text(
                  item.image.isEmpty ? '👕' : item.image,
                  style: TextStyle(fontSize: 28.sp),
                ),
              )
            : FlexibleImage(
                source: item.image,
                borderRadius: 0,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  /// السعر + العملة الجاية من الترجمة
  /// الرقم الصحيح بيتعرض من غير كسور يعني 15 مش 15.0
  String _priceLabel() {
    final value = item.price % 1 == 0
        ? item.price.toInt().toString()
        : item.price.toString();
    return '$value ${'currency'.tr()}';
  }

  /// مش مختارة يبقى زرار + دايرة، ولما تتختار الكاونتر بياخد مكانه
  Widget _buildAction() {
    if (!_isSelected) {
      return InkWell(
        onTap: onSelect,
        customBorder: const CircleBorder(),
        child: Container(
          width: 28.r,
          height: 28.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, size: 18.r, color: AppColors.whiteColor),
        ),
      );
    }

    return QuantityCounter(
      quantity: quantity,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
      compact: true,
    );
  }
}
