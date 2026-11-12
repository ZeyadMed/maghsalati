import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_price.dart';

/// فاتورة السلة قبل التأكيد: سعر القطع، والتوصيل (الاستلام + التسليم) في سطر
/// واحد، وتحت خط متعرج الإجمالي. كل الأرقام محسوبة من السيرفر
class CheckoutInvoiceCard extends StatelessWidget {
  final CartModel cart;

  const CheckoutInvoiceCard({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(
            Text('items_price'.tr(), style: _labelStyle),
            _price(cart.itemsTotal),
          ),
          SizedBox(height: 12.h),
          _buildRow(_buildDeliveryLabel(), _buildDeliveryValue()),
          SizedBox(height: 14.h),
          const _ZigzagDivider(),
          SizedBox(height: 14.h),
          _buildRow(
            Text('total'.tr(), style: TextStyles.darkBold16),
            Text(
              '${formatCartPrice(cart.totalPrice)} ${'currency'.tr()}',
              style: TextStyles.darkBold16,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => TextStyles.darkRegular14;

  Widget _buildRow(Widget label, Widget value) {
    return Row(
      children: [
        Expanded(child: label),
        SizedBox(width: 8.w),
        value,
      ],
    );
  }

  Widget _price(num value) =>
      Text('${formatCartPrice(value)} ${'currency'.tr()}', style: _labelStyle);

  /// "سعر التوصيل" وجنبه بخط أصغر إنه شامل الاستلام والتسليم
  Widget _buildDeliveryLabel() {
    return Text.rich(
      TextSpan(
        text: 'checkout_delivery_price'.tr(),
        style: _labelStyle,
        children: [
          TextSpan(
            text: ' (${'delivery_price_includes'.tr()})',
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.greyColor3,
            ),
          ),
        ],
      ),
    );
  }

  /// برا النطاق السيرفر مابيحسبش رسوم فبيتعرض "غير متاح"،
  /// وجوه النطاق لو صفر بيتعرض "مجاني" بدل 0
  Widget _buildDeliveryValue() {
    if (!cart.isDeliverable) {
      return Text(
        'delivery_unavailable'.tr(),
        style: TextStyles.darkBold12.copyWith(color: AppColors.redColor2),
      );
    }
    if (cart.deliveryFees > 0) return _price(cart.deliveryFees);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'free'.tr(),
        style: TextStyles.darkBold12.copyWith(color: AppColors.primaryColor),
      ),
    );
  }
}

/// خط متعرج زي حافة الإيصال، بيفصل البنود عن الإجمالي
class _ZigzagDivider extends StatelessWidget {
  const _ZigzagDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: CustomPaint(
        painter: _ZigzagPainter(color: AppColors.greyColor5, step: 7.w),
      ),
    );
  }
}

class _ZigzagPainter extends CustomPainter {
  final Color color;
  final double step;

  const _ZigzagPainter({required this.color, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(0, size.height);
    var x = 0.0;
    var up = true;
    while (x < size.width) {
      x += step;
      path.lineTo(x.clamp(0, size.width), up ? 0 : size.height);
      up = !up;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ZigzagPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.step != step;
}
