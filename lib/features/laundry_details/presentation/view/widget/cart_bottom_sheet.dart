import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/quantity_counter.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// البوتوم شيت بتاع السلة: القطع اللي اتضافت بكمياتها، وتحتها الإجمالي
/// وزرار إتمام الطلب. الكميات بتتعدل من جواها على طول والكارت بيتحدث معاها
/// لأن الاتنين بيقروا من نفس الكنترولر
class CartBottomSheet extends StatelessWidget {
  final SelectedServicesController controller;
  final List<ServiceCategoryModel> categories;

  /// بيتنفذ لما يدوس على إتمام الطلب، بعد ما الشيت يتقفل
  final VoidCallback? onConfirm;

  const CartBottomSheet({
    super.key,
    required this.controller,
    required this.categories,
    this.onConfirm,
  });

  /// بيفتح الشيت، وبيرجع لما يتقفل
  static Future<void> show({
    required BuildContext context,
    required SelectedServicesController controller,
    required List<ServiceCategoryModel> categories,
    VoidCallback? onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CartBottomSheet(
        controller: controller,
        categories: categories,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.selectedServices(categories);

        return Container(
          // أقصى ارتفاع تلت الشاشة تقريبا عشان القايمة الطويلة تتسكرول جواها
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                _buildHeader(context),
                Divider(height: 1, color: AppColors.borderColor),
                Flexible(
                  child: selected.isEmpty
                      ? _buildEmpty()
                      : _buildItemsList(selected),
                ),
                if (selected.isNotEmpty) _buildFooter(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
      width: 44.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.greyColor5,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 8.w, 10.h),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${'your_order'.tr()} (${controller.totalPieces} ${'piece'.tr()})',
              style: TextStyles.darkBold16,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.close, size: 20.r, color: AppColors.greyColor2),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Text(
          'cart_empty'.tr(),
          style: TextStyles.greyColor2Regular14,
        ),
      ),
    );
  }

  Widget _buildItemsList(List<SelectedService> selected) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: selected.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) => _buildLine(selected[index]),
    );
  }

  /// سطر القطعة: الصورة والاسم والحساب، وعلى الجنب الكاونتر
  Widget _buildLine(SelectedService service) {
    final item = service.item;
    final lineTotal = item.price * service.quantity;

    return Row(
      children: [
        _buildThumbnail(item),
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
                '${_formatPrice(item.price)} ${'currency'.tr()} × '
                '${service.quantity} = ${_formatPrice(lineTotal)} '
                '${'currency'.tr()}',
                style: TextStyles.greyColor2Regular14.copyWith(fontSize: 11.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        QuantityCounter(
          quantity: service.quantity,
          onIncrement: () => controller.increment(item.id),
          onDecrement: () => controller.decrement(item.id),
          compact: true,
        ),
      ],
    );
  }

  /// صورة القطعة الصغيرة على جنب السطر
  /// الصورة ممكن تكون لينك أو إيموجي جاي من السيرفر، زي ما في كارت الجريد
  Widget _buildThumbnail(ServiceItemModel item) {
    final isEmoji = !item.image.startsWith('http');

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
      child: isEmoji
          ? Text(
              item.image.isEmpty ? '👕' : item.image,
              style: TextStyle(fontSize: 22.sp),
            )
          : FlexibleImage(
              source: item.image,
              borderRadius: 0,
              fit: BoxFit.cover,
              width: 48.r,
              height: 48.r,
            ),
    );
  }

  /// الإجمالي بتفاصيله وتحته زرار إتمام الطلب
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTotalRow('services_total'.tr(), controller.servicesTotal),
          if (controller.deliveryPrice > 0) ...[
            SizedBox(height: 6.h),
            _buildTotalRow('delivery_price'.tr(), controller.deliveryPrice),
          ],
          SizedBox(height: 8.h),
          Divider(height: 1, color: AppColors.borderColor),
          SizedBox(height: 8.h),
          _buildTotalRow('total'.tr(), controller.grandTotal, emphasized: true),
          SizedBox(height: 12.h),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, num value, {bool emphasized = false}) {
    final style = emphasized
        ? TextStyles.darkBold16
        : TextStyles.greyColor2Regular14;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text('${_formatPrice(value)} ${'currency'.tr()}', style: style),
      ],
    );
  }

  /// بيقفل الشيت الأول وبعدين ينفذ التأكيد عشان مايفضلش فوق الشاشة الجديدة
  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm?.call();
        },
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

  /// الرقم الصحيح بيتعرض من غير كسور يعني 8 مش 8.0
  String _formatPrice(num value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
}
