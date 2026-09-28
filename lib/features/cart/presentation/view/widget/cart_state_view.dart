import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';

/// بيسمع على [CartCubit] وبيعرض اللودينج أو الخطأ أو السلة الفاضية،
/// ولما السلة يبقى فيها حاجة بيسيب [builder] يرسمها.
/// مشترك بين شيت السلة وتاب السلة عشان الحالات دي تبقى واحدة في الاتنين
class CartStateView extends StatelessWidget {
  final CartCubit cubit;
  final Widget Function(BuildContext context, CartModel cart) builder;

  /// نسخة الشاشة الكاملة: السلة الفاضية بالأيقونة والهينت والحالات في النص،
  /// والشيت بيستخدم نسخة أصغر
  final bool fullEmptyState;

  const CartStateView({
    super.key,
    required this.cubit,
    required this.builder,
    this.fullEmptyState = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, BaseState<CartModel>>(
      bloc: cubit,
      // الفشل والسلة ظاهرة (زي تعديل كمية وقع) بيبان كرسالة
      // بدل ما السلة تختفي، أما من غير سلة فبتظهر شاشة الخطأ تحت
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.isFailure &&
          current.data != null,
      listener: (context, state) =>
          context.showErrorMessage(state.errorMessage ?? 'try_again'.tr()),
      builder: (context, state) {
        final cart = state.data;

        // لو فيه سلة قديمة بنعرضها وقت التحديث بدل ما الشاشة ترمش
        if (cart == null) {
          if (state.isFailure) return _center(_buildError(state.errorMessage));
          return _center(_buildLoading());
        }

        if (cart.isEmpty) return _center(_buildEmpty());
        return builder(context, cart);
      },
    );
  }

  /// في التاب الحالات دي بتتوسّط الشاشة، أما في الشيت فبتاخد مساحتها بس
  /// عشان الشيت مايتمدش لآخر ارتفاعه
  Widget _center(Widget child) =>
      fullEmptyState ? Center(child: child) : child;

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildError(String? message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 56.r, color: AppColors.greyColor5),
          SizedBox(height: 12.h),
          Text(
            message ?? 'try_again'.tr(),
            style: TextStyles.darkBold16,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: cubit.getCart,
            child: Text(
              'try_again'.tr(),
              style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    if (!fullEmptyState) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text('cart_empty'.tr(), style: TextStyles.greyColor2Regular14),
        ),
      );
    }

    return Padding(
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
    );
  }
}
