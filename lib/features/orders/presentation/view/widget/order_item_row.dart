import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// سطر القطعة في شاشة التفاصيل: صورتها واسمها وكميتها وسعرها
class OrderItemRow extends StatelessWidget {
  final OrderItemModel item;

  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildImage(),
        Gap(12.w),
        Expanded(child: _buildNameAndQuantity()),
        Gap(12.w),
        _buildPrice(),
      ],
    );
  }

  /// الصورة ممكن تكون لينك من السيرفر أو إيموجي، ولو فاضية بيبان أيقونة بديلة
  Widget _buildImage() {
    final size = 52.r;

    if (item.image.isEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.checkroom_rounded,
          size: 24.r,
          color: AppColors.greyColor4,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: FlexibleImage(
        source: item.image,
        width: size,
        height: size,
        borderRadius: 12,
      ),
    );
  }

  /// اسم القطعة وتحته الكمية × سعر القطعة
  /// ولو العميل رفض التعديل عليها بيبان جنب اسمها إنها راجعة من غير غسيل
  Widget _buildNameAndQuantity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                item.name,
                style: TextStyles.darkBold14.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.isReturned) ...[Gap(6.w), _buildReturnedChip()],
          ],
        ),
        Gap(4.h),
        Text(
          '${item.quantity} ${'piece'.tr()} × '
          '${formatOrderPrice(item.price)} ${'currency'.tr()}',
          style: TextStyles.darkRegular12.copyWith(
            color: AppColors.greyColor3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildReturnedChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.redColor2.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'returned_item'.tr(),
        style: TextStyles.darkBold12.copyWith(color: AppColors.redColor2),
      ),
    );
  }

  /// سعر السطر كله (الكمية × سعر القطعة)، ومتشطب لو القطعة راجعة
  /// لأن سعرها اتشال من الإجمالي
  Widget _buildPrice() {
    return Text(
      '${formatOrderPrice(item.total)} ${'currency'.tr()}',
      style: TextStyles.darkBold14.copyWith(
        fontWeight: FontWeight.w700,
        color: item.isReturned ? AppColors.greyColor3 : null,
        decoration: item.isReturned ? TextDecoration.lineThrough : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
