import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/cart/data/model/cart_item_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_price.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/quantity_counter.dart';

/// سطر القطعة في السلة: الصورة والاسم والحساب، وعلى الجنب كاونتر الكمية
/// كل + أو - بيبعت الكمية الجديدة للسيرفر عن طريق [onQuantityChanged]
/// وأيقونة المسح بتشيل السطر كله عن طريق [onRemove]
/// وبيتستخدم في شيت السلة وتاب السلة، و [boxed] بيحطه جوا كارت
class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final bool boxed;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  /// الكمية بتتعدل على السيرفر، فالكاونتر بيتبدل بلودينج لحد ما يخلص
  final bool isUpdating;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.isUpdating = false,
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        _buildThumbnail(),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
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
                '${formatCartPrice(item.unitPrice)} ${'currency'.tr()} × '
                '${item.quantity} = ${formatCartPrice(item.lineTotal)} '
                '${'currency'.tr()}',
                style: TextStyles.greyColor2Regular14.copyWith(fontSize: 11.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        _buildQuantity(),
        _buildRemove(),
      ],
    );

    if (!boxed) return row;

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: row,
    );
  }

  /// الكاونتر بياخد نفس المساحة وهو بيحمل عشان السطر مايتهزش
  Widget _buildQuantity() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isUpdating ? 0.3 : 1,
          child: IgnorePointer(
            ignoring: isUpdating,
            child: QuantityCounter(
              quantity: item.quantity,
              onIncrement: () => onQuantityChanged(item.quantity + 1),
              onDecrement: () => onQuantityChanged(item.quantity - 1),
              compact: true,
            ),
          ),
        ),
        if (isUpdating)
          SizedBox(
            width: 16.r,
            height: 16.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
      ],
    );
  }

  /// بتتقفل وقت التعديل عشان مايتبعتش مسح والكمية لسه بتتحدث
  Widget _buildRemove() {
    return IconButton(
      onPressed: isUpdating ? null : onRemove,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
      icon: Icon(
        Icons.delete_outline,
        size: 20.r,
        color: isUpdating ? AppColors.greyColor5 : AppColors.redColor2,
      ),
    );
  }

  /// الصورة ممكن تكون لينك أو فاضية، ولو فاضية بيبان إيموجي
  Widget _buildThumbnail() {
    final isUrl = item.image.startsWith('http');

    return Container(
      width: 48.r,
      height: 48.r,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      alignment: Alignment.center,
      child: isUrl
          ? FlexibleImage(
              source: item.image,
              borderRadius: 0,
              fit: BoxFit.cover,
              width: 48.r,
              height: 48.r,
            )
          : Text(
              item.image.isEmpty ? '👕' : item.image,
              style: TextStyle(fontSize: 22.sp),
            ),
    );
  }
}
