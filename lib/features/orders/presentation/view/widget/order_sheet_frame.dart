import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// بيفتح شيت من شيتات الطلب بنفس إعدادات شيت تأكيد السلة
Future<T?> showOrderSheet<T>(BuildContext context, Widget sheet) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => sheet,
  );
}

/// الإطار المشترك لشيتات الطلب (مراجعة التعديل وتأكيد الاستلام والتقييم)
/// بنفس شكل شيت تأكيد السلة: مقبض وعنوان بأيقونة وزرار قفل والمحتوى تحته،
/// و[footer] بيفضل ثابت تحت والمحتوى هو اللي بيسكرول
class OrderSheetFrame extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? footer;

  const OrderSheetFrame({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // الشيت بيطلع فوق الكيبورد عشان الخانات ماتستخباش
      padding: EdgeInsets.only(bottom: context.keyboardHeight),
      child: Container(
        constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: child,
                ),
              ),
              if (footer != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
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
          Icon(icon, size: 20.r, color: AppColors.primaryColor),
          SizedBox(width: 8.w),
          Expanded(child: Text(title, style: TextStyles.darkBold16)),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.close, size: 20.r, color: AppColors.greyColor2),
          ),
        ],
      ),
    );
  }
}

/// رسالة الخطأ جوه الشيت فوق الزراير، لأن السناك بار بيطلع تحت الشيت ومابيبانش
class SheetErrorText extends StatelessWidget {
  final String? message;

  const SheetErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null || message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        message,
        style: TextStyles.darkRegular12.copyWith(color: AppColors.redColor2),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// زرار الشيت بلودينج، مليان بلون البراند أو فاتح بلون [color]
class SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool filled;
  final Color color;

  const SheetButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.filled = true,
    this.color = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.whiteColor : color;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? color : color.withValues(alpha: 0.12),
          foregroundColor: foreground,
          disabledBackgroundColor: (filled ? color : color.withValues(alpha: 0.12))
              .withValues(alpha: 0.6),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : Text(
                label,
                style: TextStyles.whiteBold15.copyWith(color: foreground),
              ),
      ),
    );
  }
}
