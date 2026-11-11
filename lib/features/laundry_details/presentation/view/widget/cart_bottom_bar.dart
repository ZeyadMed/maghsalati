import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_price.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/count_badge.dart';

/// البار اللي تحت شاشة المغسلة وشاشة القطع على شكل التطبيق الصيني:
/// زرار أزرق بعرض الشاشة و"تأكيد الطلب" في النص
/// لما يبقى فيه قطع بتظهر جواه السلة بالعدد على جنب، والسعر التقديري على الجنب التاني
/// الأرقام بتيجي جاهزة من الشاشة، فالبار مايعرفش حاجة عن السلة نفسها
class CartBottomBar extends StatelessWidget {
  final int pieces;

  /// إجمالي القطع من غير التوصيل، والتوصيل بيبان في شيت السلة
  final num estimatedPrice;

  /// فيه قطع لسه بتتبعت للسلة، فالزرار بيعرض لودينج ومابيتداسش
  final bool isBusy;

  /// بيفتح شيت السلة اللي فيه تعديل الكميات والمسح
  final VoidCallback? onBasketTap;
  final VoidCallback? onConfirm;

  const CartBottomBar({
    super.key,
    required this.pieces,
    required this.estimatedPrice,
    this.isBusy = false,
    this.onBasketTap,
    this.onConfirm,
  });

  /// عرض كل جنب ثابت عشان الكلام يفضل في نص البار مهما كان السعر
  double get _sideWidth => 92.w;

  bool get _hasPieces => pieces > 0;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: AppColors.primaryColor,
      child: InkWell(
        onTap: isBusy ? null : () => _onConfirmTap(context),
        // الزرار واخد البار لحد تحت خالص، والكلام بيترفع فوق شريط النظام
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SizedBox(
            height: 54.h,
            child: Row(
              children: [
                // SizedBox(
                //   width: _sideWidth,
                //   child: _hasPieces ? _buildBasket() : null,
                // ),
                Expanded(child: Center(child: _buildLabel())),
                // SizedBox(
                //   width: _sideWidth,
                //   child: _hasPieces ? _buildPrice() : null,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// البار فاضل أزرق زي التصميم حتى والسلة فاضية، فالدوسة ساعتها بتقول إنها فاضية
  void _onConfirmTap(BuildContext context) {
    if (!_hasPieces) {
      context.showSuccessMessage(
        'cart_empty'.tr(),
        icon: Icons.info_outline_rounded,
        color: AppColors.primaryColor,
      );
      return;
    }
    onConfirm?.call();
  }

  Widget _buildLabel() {
    if (isBusy) {
      return SizedBox(
        width: 20.r,
        height: 20.r,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.whiteColor,
        ),
      );
    }
    return Text(
      'confirm_order'.tr(),
      style: TextStyles.whiteText(17, weight: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// أيقونة سلة بيضا عليها العدد، ليها دوسة لوحدها غير دوسة التأكيد
  Widget _buildBasket() {
    return GestureDetector(
      onTap: onBasketTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 16.w),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                size: 28.r,
                color: AppColors.whiteColor,
              ),
              PositionedDirectional(
                top: -8.r,
                end: -12.r,
                child: CountBadge(count: pieces),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// السعر بخط عريض وتحته "السعر التقديري" صغير،
  /// وبيصغر بدل ما يقص الرقم لو الخط كبير أو السعر طويل
  Widget _buildPrice() {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 16.w),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${formatCartPrice(estimatedPrice)} ${'currency'.tr()}',
              style: TextStyles.whiteText(16),
            ),
            Text(
              'estimated_price'.tr(),
              style: TextStyles.whiteText(
                10,
                weight: FontWeight.w400,
              ).copyWith(color: AppColors.whiteColor.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    );
  }
}
