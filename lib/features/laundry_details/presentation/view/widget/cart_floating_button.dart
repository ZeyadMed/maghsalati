import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// زرار السلة العايم، وعليه بادج بعدد القطع المختارة
/// بيسمع للكنترولر فالرقم بيتغير مع كل قطعة تتزود أو تتشال
/// ومابيبانش خالص لو السلة فاضية
class CartFloatingButton extends StatelessWidget {
  final SelectedServicesController controller;
  final VoidCallback? onTap;

  const CartFloatingButton({super.key, required this.controller, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final pieces = controller.totalPieces;
        if (pieces == 0) return const SizedBox.shrink();

        return FloatingActionButton(
          onPressed: onTap,
          backgroundColor: AppColors.primaryColor,
          shape: const CircleBorder(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.whiteColor,
                size: 24.r,
              ),
              PositionedDirectional(
                top: -8.h,
                end: -10.w,
                child: _buildBadge(pieces),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(int pieces) {
    return Container(
      constraints: BoxConstraints(minWidth: 18.r),
      height: 18.r,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.redColor2,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: AppColors.whiteColor, width: 1.5),
      ),
      child: Text(
        '$pieces',
        style: TextStyles.whiteText(10, weight: FontWeight.bold),
      ),
    );
  }
}
