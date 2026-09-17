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
  Widget _buildNameAndQuantity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.name,
          style: TextStyles.darkBold14.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  /// سعر السطر كله (الكمية × سعر القطعة)
  Widget _buildPrice() {
    return Text(
      '${formatOrderPrice(item.total)} ${'currency'.tr()}',
      style: TextStyles.darkBold14.copyWith(fontWeight: FontWeight.w700),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
