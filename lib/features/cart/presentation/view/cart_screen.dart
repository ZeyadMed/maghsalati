import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/quantity_counter.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';

/// تاب السلة في البوتوم ناف: نفس ديزاين شيت السلة اللي في تفاصيل المغسلة
/// بس كشاشة كاملة. بيقرا من نفس الكنترولر اللي في get_it فأي حاجة تتضاف
/// من شاشة القطع بتبان هنا على طول
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  /// نفس الانستانس اللي شاشة التفاصيل بتملاه، مش بيتعمله dispose هنا
  /// لأنه singleton في get_it وشاشات تانية بتستخدمه
  final SelectedServicesController _controller =
      getIt<SelectedServicesController>();

  /// بيبني الطلب من السلة ويودي على شاشة انتظار موافقة المغسلة
  /// TODO: ابعت الطلب على ال endpoint هنا الأول لما يجهز
  void _onConfirmOrder() {
    final selected = _controller.currentSelection;
    if (selected.isEmpty) return;

    final order = PendingOrderModel(
      laundryName: _controller.laundryName,
      deliveryPrice: _controller.deliveryPrice,
      lines: selected
          .map(
            (service) => PendingOrderLine(
              itemId: service.item.id,
              name: service.item.name,
              quantity: service.quantity,
              price: service.item.price,
            ),
          )
          .toList(),
    );

    context.push(AppRouter.orderPending, extra: order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final selected = _controller.currentSelection;

          if (selected.isEmpty) return _buildEmpty();

          return Column(
            children: [
              Expanded(child: _buildItemsList(selected)),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  /// الأبار فيه عدد القطع، وبيتحدث مع الكنترولر زي هيدر الشيت
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pieces = _controller.totalPieces;

          return Text(
            pieces == 0
                ? 'your_order'.tr()
                : '${'your_order'.tr()} ($pieces ${'piece'.tr()})',
            style: TextStyles.darkBold18,
          );
        },
      ),
    );
  }

  /// السلة فاضية: أيقونة ورسالة وزرار يوديه يتصفح المغاسل
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72.r,
              color: AppColors.greyColor5,
            ),
            SizedBox(height: 16.h),
            Text(
              'cart_empty'.tr(),
              style: TextStyles.darkBold16,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'cart_empty_hint'.tr(),
              style: TextStyles.greyColor2Regular14,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// اسم المغسلة فوق اللستة عشان يعرف الطلب رايح لمين
  Widget _buildLaundryBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_laundry_service_outlined,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _controller.laundryName,
              style: TextStyles.darkBold14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<SelectedService> selected) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      // بانر المغسلة بيتحسب كأول عنصر في اللستة عشان يتسكرول معاها
      itemCount: selected.length + 1,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        if (index == 0) return _buildLaundryBanner();
        return _buildLine(selected[index - 1]);
      },
    );
  }

  /// سطر القطعة: الصورة والاسم والحساب، وعلى الجنب الكاونتر
  Widget _buildLine(SelectedService service) {
    final item = service.item;
    final lineTotal = item.price * service.quantity;

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
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
                  style: TextStyles.greyColor2Regular14.copyWith(
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          QuantityCounter(
            quantity: service.quantity,
            onIncrement: () => _controller.increment(item.id),
            onDecrement: () => _controller.decrement(item.id),
            compact: true,
          ),
        ],
      ),
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

  /// الإجمالي بتفاصيله وتحته زرار إتمام الطلب، نفس فوتر الشيت
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTotalRow('services_total'.tr(), _controller.servicesTotal),
            if (_controller.deliveryPrice > 0) ...[
              SizedBox(height: 6.h),
              _buildTotalRow('delivery_price'.tr(), _controller.deliveryPrice),
            ],
            SizedBox(height: 8.h),
            Divider(height: 1, color: AppColors.borderColor),
            SizedBox(height: 8.h),
            _buildTotalRow(
              'total'.tr(),
              _controller.grandTotal,
              emphasized: true,
            ),
            SizedBox(height: 12.h),
            _buildConfirmButton(),
          ],
        ),
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

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onConfirmOrder,
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
