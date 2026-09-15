import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الكاونتر بتاع الكمية: زرار + وزرار - وبينهم البوكس بتاع الرقم
class QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantityCounter({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    // ترتيب ثابت زي الديزاين: + على الشمال والرقم في النص و - على اليمين
    // فبنثبت اتجاه الصف عشان مايتقلبش مع اللغة
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(icon: Icons.add, onTap: onIncrement),
        SizedBox(width: 8.w),
        Container(
          width: 42.w,
          height: 30.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primaryColor, width: 1),
          ),
          child: Text('$quantity', style: TextStyles.darkBold14),
        ),
        SizedBox(width: 8.w),
        _buildButton(icon: Icons.remove, onTap: onDecrement),
      ],
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 30.r,
        height: 30.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.r, color: AppColors.whiteColor),
      ),
    );
  }
}
