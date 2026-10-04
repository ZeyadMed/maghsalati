import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_price.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/count_badge.dart';

/// البار اللي تحت شاشة المغسلة وشاشة القطع زي الديزاين: سلة على الجنب
/// عليها عدد القطع، وجنبها السعر التقديري، وزرار تأكيد الطلب على الطرف التاني،
/// وفوقهم سطر بيفكّر إن السعر النهائي بيتأكد بعد مراجعة المغسلة
/// الأرقام بتيجي جاهزة من الشاشة، فالبار مايعرفش حاجة عن السلة نفسها
class CartBottomBar extends StatelessWidget {
  final int pieces;

  /// إجمالي القطع من غير التوصيل
  final num estimatedPrice;

  /// رسوم الاستلام + التسليم، ولو صفر بيبان "غير شامل التوصيل"
  final num deliveryFees;

  /// فيه قطع لسه بتتبعت للسلة، فالزرار بيعرض لودينج ومابيتداسش
  final bool isBusy;
  final VoidCallback? onBasketTap;
  final VoidCallback? onConfirm;

  const CartBottomBar({
    super.key,
    required this.pieces,
    required this.estimatedPrice,
    this.deliveryFees = 0,
    this.isBusy = false,
    this.onBasketTap,
    this.onConfirm,
  });

  double get _basketSize => 60.r;

  double get _barHeight => 56.h;

  bool get _hasPieces => pieces > 0;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildNotice(), _buildBar(bottomInset)],
        ),
        // السلة طالعة شوية فوق سطر الملاحظة زي الديزاين، وجوه حدود الـ Stack
        // عشان الدوسة على الجزء الطالع تتحسب
        PositionedDirectional(
          start: 16.w,
          bottom: bottomInset + 6.h,
          child: _buildBasket(),
        ),
      ],
    );
  }

  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      // مسافة من ناحية السلة عشان الكلام مايستخباش تحتها
      padding: EdgeInsetsDirectional.fromSTEB(
        16.w + _basketSize + 10.w,
        7.h,
        16.w,
        7.h,
      ),
      color: Color.alphaBlend(
        AppColors.lightOrangeColor.withValues(alpha: 0.18),
        AppColors.whiteColor,
      ),
      child: Text(
        'price_confirm_note'.tr(),
        style: TextStyles.darkRegular12,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// الزرار واخد البار لحد تحت خالص، والكلام بيترفع فوق شريط النظام
  Widget _buildBar(double bottomInset) {
    return Container(
      height: _barHeight + bottomInset,
      color: AppColors.whiteColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // مكان السلة اللي فوق البار
          SizedBox(width: 16.w + _basketSize + 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: _buildPrice(),
            ),
          ),
          _buildConfirmButton(bottomInset),
        ],
      ),
    );
  }

  Widget _buildBasket() {
    return GestureDetector(
      onTap: _hasPieces ? onBasketTap : null,
      child: Container(
        width: _basketSize,
        height: _basketSize,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 30.r,
              color: _hasPieces ? AppColors.primaryColor : AppColors.greyColor5,
            ),
            if (_hasPieces)
              PositionedDirectional(
                top: 4.r,
                end: 4.r,
                child: CountBadge(count: pieces),
              ),
          ],
        ),
      ),
    );
  }

  /// "السعر التقديري 139 د.ل" وتحته التوصيل
  Widget _buildPrice() {
    final priceColor = _hasPieces
        ? AppColors.redColor2
        : AppColors.greyColor3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // بيصغر بدل ما يقص الرقم لو الخط كبير أو السعر طويل
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'estimated_price'.tr(),
                style: TextStyles.boldStyle(
                  12,
                  color: priceColor,
                  weight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '${formatCartPrice(estimatedPrice)} ${'currency'.tr()}',
                style: TextStyles.boldStyle(20, color: priceColor),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _deliveryLabel(),
          style: TextStyles.greyColor2Regular14.copyWith(fontSize: 11.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// "+ توصيل 8 د.ل" لو السيرفر حسب التوصيل، وإلا "غير شامل التوصيل"
  String _deliveryLabel() {
    if (deliveryFees <= 0) return 'delivery_not_included'.tr();
    return '+ ${'delivery_price'.tr()} ${formatCartPrice(deliveryFees)} '
        '${'currency'.tr()}';
  }

  /// من غير قطع الزرار بيتقفل، ووقت ما القطع بتتبعت بيعرض لودينج
  Widget _buildConfirmButton(double bottomInset) {
    final enabled = _hasPieces && !isBusy && onConfirm != null;

    return Material(
      color: _hasPieces ? AppColors.primaryColor : AppColors.greyColor5,
      child: InkWell(
        onTap: enabled ? onConfirm : null,
        child: Container(
          width: 130.w,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: isBusy
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.whiteColor,
                  ),
                )
              : Text('confirm_order'.tr(), style: TextStyles.whiteBold15),
        ),
      ),
    );
  }
}
