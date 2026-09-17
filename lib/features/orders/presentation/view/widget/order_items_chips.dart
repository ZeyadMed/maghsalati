import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// شيبس مختصرة بأسماء القطع وكمياتها (3 قمصان - 2 بنطلون ...)
/// بتلف لسطر تاني لوحدها لو القطع كتيرة
class OrderItemsChips extends StatelessWidget {
  final List<OrderItemModel> items;

  const OrderItemsChips({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map(_buildChip).toList(),
    );
  }

  Widget _buildChip(OrderItemModel item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '${item.quantity} ${item.name}',
        style: TextStyles.darkRegular12.copyWith(
          color: AppColors.greyColor2,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
