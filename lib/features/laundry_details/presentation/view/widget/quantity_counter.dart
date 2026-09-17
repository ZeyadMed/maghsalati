import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الكاونتر بتاع الكمية: زرار + وزرار - وبينهم البوكس بتاع الرقم
/// و compact نسخة أصغر بتتحط جوا كروت الجريد اللي مساحتها ضيقة
class QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QuantityCounter({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  double get _buttonSize => compact ? 24.r : 30.r;

  double get _gap => compact ? 6.w : 8.w;

  @override
  Widget build(BuildContext context) {
    // ترتيب ثابت زي الديزاين: + على الشمال والرقم في النص و - على اليمين
    // فبنثبت اتجاه الصف عشان مايتقلبش مع اللغة
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(icon: Icons.add, onTap: onIncrement),
        SizedBox(width: _gap),
        Container(
          width: compact ? 28.w : 42.w,
          height: compact ? 24.h : 30.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primaryColor, width: 1),
          ),
          child: Text(
            '$quantity',
            style: compact
                ? TextStyles.darkBold12.copyWith(fontSize: 11.sp)
                : TextStyles.darkBold14,
          ),
        ),
        SizedBox(width: _gap),
        _buildButton(icon: Icons.remove, onTap: onDecrement),
      ],
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: _buttonSize,
        height: _buttonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: compact ? 14.r : 18.r,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}
