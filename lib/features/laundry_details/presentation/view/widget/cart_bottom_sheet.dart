import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_item_tile.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_state_view.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_summary.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';

/// البوتوم شيت بتاع السلة: بيعرض سلة العميل الجاية من api/customer/cart
/// وتحتها الإجمالي وزرار إتمام الطلب. بيقرا من نفس الـ cubit بتاع تاب السلة
class CartBottomSheet extends StatefulWidget {
  /// بيتنفذ بالسلة لما يدوس على إتمام الطلب، بعد ما الشيت يتقفل
  final ValueChanged<CartModel>? onConfirm;

  const CartBottomSheet({super.key, this.onConfirm});

  /// بيفتح الشيت، وبيرجع لما يتقفل
  static Future<void> show({
    required BuildContext context,
    ValueChanged<CartModel>? onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CartBottomSheet(onConfirm: onConfirm),
    );
  }

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  /// singleton في get_it فمش بيتعمله close هنا
  final CartCubit _cartCubit = getIt<CartCubit>();

  @override
  void initState() {
    super.initState();
    // كل مرة الشيت يتفتح بنجيب أحدث سلة من السيرفر
    _cartCubit.getCart();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // أقصى ارتفاع 80% من الشاشة عشان القايمة الطويلة تتسكرول جواها
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
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
              child: CartStateView(
                cubit: _cartCubit,
                builder: (context, cart) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: _buildItemsList(cart)),
                    CartSummary(
                      cart: cart,
                      onConfirm: () => _onConfirm(context, cart),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بيقفل الشيت الأول وبعدين ينفذ التأكيد عشان مايفضلش فوق الشاشة الجديدة
  void _onConfirm(BuildContext context, CartModel cart) {
    Navigator.of(context).pop();
    widget.onConfirm?.call(cart);
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
          Icon(
            Icons.shopping_cart_outlined,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: BlocBuilder<CartCubit, BaseState<CartModel>>(
              bloc: _cartCubit,
              builder: (context, state) {
                final pieces = state.data?.totalPieces ?? 0;
                return Text(
                  '${'your_order'.tr()} ($pieces ${'piece'.tr()})',
                  style: TextStyles.darkBold16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.close, size: 20.r, color: AppColors.greyColor2),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(CartModel cart) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: cart.items.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return CartItemTile(
          item: item,
          isUpdating: _cartCubit.isUpdating(item),
          onQuantityChanged: (quantity) =>
              _cartCubit.updateQuantity(item, quantity),
        );
      },
    );
  }
}
