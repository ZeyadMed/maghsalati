import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';

/// زرار السلة العايم، وعليه بادج بعدد القطع اللي في سلة السيرفر
/// بيسمع على [CartCubit] مش على الكاونتر، فالرقم مابيتغيرش مع + و -
/// وبيتحدث بس لما "أضف للسلة" ينجح والسلة تتجاب تاني
/// ومابيبانش خالص لو السلة فاضية
class CartFloatingButton extends StatelessWidget {
  final CartCubit cartCubit;
  final VoidCallback? onTap;

  const CartFloatingButton({super.key, required this.cartCubit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, BaseState<CartModel>>(
      bloc: cartCubit,
      // السلة القديمة بتفضل في الستيت وقت التحديث، فالرقم مابيرمشش
      buildWhen: (previous, current) =>
          previous.data?.totalPieces != current.data?.totalPieces,
      builder: (context, state) {
        final pieces = state.data?.totalPieces ?? 0;
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
