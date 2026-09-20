import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_item_row.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_progress_tracker.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_badge.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';

/// شاشة تفاصيل الطلب: بيانات الطلب وقطعه بصورها وأسعارها والإجمالي في الآخر
/// بتتفتح من زرار "عرض التفاصيل" في كروت الطلبات بتوعها الاتنين
class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'order_details',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(context),
            Gap(14.h),
            _buildItemsCard(),
            Gap(14.h),
            _buildTotalsCard(),
          ],
        ),
      ),
    );
  }

  /// كارت فوق: اسم المغسلة ورقم الطلب وتاريخه وحالته
  /// وشريط الخطوات بيبان بس لو الطلب لسه شغال
  Widget _buildInfoCard(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.laundryName,
                      style: TextStyles.darkBold16.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(4.h),
                    Text(
                      DateFormat(
                        'd MMMM yyyy',
                        context.locale.toString(),
                      ).format(order.date),
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor3,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(2.h),
                    Text(
                      '${'order_number'.tr()}: ${order.reference}',
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor3,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gap(12.w),
              OrderStatusBadge(status: order.status),
            ],
          ),
          if (order.isCurrent) ...[
            Gap(18.h),
            OrderProgressTracker(status: order.status),
          ],
        ],
      ),
    );
  }

  /// كارت القطع: كل قطعة بصورتها واسمها وكميتها وسعرها
  Widget _buildItemsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'order_items'.tr(),
                  style: TextStyles.darkBold16.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Gap(12.w),
              Text(
                '${order.totalPieces} ${'piece'.tr()}',
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
              ),
            ],
          ),
          Gap(14.h),
          // الفاصل بيتحط بين القطع بس، مش تحت آخر واحدة
          for (int i = 0; i < order.items.length; i++) ...[
            if (i > 0) ...[
              Gap(12.h),
              Divider(height: 1.h, color: AppColors.lightGreyColor),
              Gap(12.h),
            ],
            OrderItemRow(item: order.items[i]),
          ],
        ],
      ),
    );
  }

  /// كارت الحساب: مجموع القطع + التوصيل وتحتهم الإجمالي النهائي
  Widget _buildTotalsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAmountRow('items_total'.tr(), order.itemsTotal),
          Gap(10.h),
          _buildAmountRow('delivery_price'.tr(), order.deliveryPrice),
          Gap(12.h),
          Divider(height: 1.h, color: AppColors.lightGreyColor),
          Gap(12.h),
          _buildGrandTotalRow(),
        ],
      ),
    );
  }

  /// سطر مبلغ عادي: اسمه على جنب وقيمته على التاني
  Widget _buildAmountRow(String label, num amount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyles.darkRegular14.copyWith(
              color: AppColors.greyColor2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(12.w),
        Text(
          '${formatOrderPrice(amount)} ${'currency'.tr()}',
          style: TextStyles.darkBold14,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// الإجمالي النهائي بعد ما التوصيل ينضاف
  Widget _buildGrandTotalRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'total'.tr(),
            style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(12.w),
        Text(
          '${formatOrderPrice(order.grandTotal)} ${'currency'.tr()}',
          style: TextStyles.blueBold20.copyWith(fontSize: 18.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// نفس شكل كروت الطلبات عشان الشاشتين يبقوا متسقين
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
