import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_item_tile.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_state_view.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_summary.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/confirm_cart_bottom_sheet.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';

/// تاب السلة في البوتوم ناف: بيعرض سلة العميل الجاية من api/customer/cart
/// الـ cubit singleton ومشترك مع شيت السلة، وبيتحدث كل ما التاب يتفتح
/// أو قطعة تتضاف للسلة
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  /// singleton في get_it فمش بيتعمله close هنا
  final CartCubit _cartCubit = getIt<CartCubit>();

  @override
  void initState() {
    super.initState();
    _cartCubit.getCart();
  }

  /// بيفتح شيت بيانات الاستلام، ولما السيرفر يأكد الطلب بيودي على شاشة
  /// انتظار موافقة المغسلة ويحدث السلة لأنها بتفضى بعد التأكيد
  Future<void> _onConfirmOrder(CartModel cart) async {
    if (cart.isEmpty) return;
    final confirmed = await ConfirmCartBottomSheet.show(context);
    if (!confirmed || !mounted) return;
    _cartCubit.getCart();
    context.push(AppRouter.orderPending, extra: cart.toPendingOrder());
  }

  /// بنأكد قبل مسح السلة كلها عشان مايمسحهاش بالغلط
  Future<void> _confirmClearCart() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('clear_cart'.tr(), style: TextStyles.darkBold16),
        content: Text(
          'clear_cart_message'.tr(),
          style: TextStyles.greyColor2Regular14,
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text('cancel'.tr(), style: TextStyles.greyColor2Regular14),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              'clear_cart'.tr(),
              style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
            ),
          ),
        ],
      ),
    );

    if (clear ?? false) _cartCubit.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _cartCubit.getCart,
        child: CartStateView(
          cubit: _cartCubit,
          fullEmptyState: true,
          builder: (context, cart) => Column(
            children: [
              Expanded(child: _buildItemsList(cart)),
              CartSummary(cart: cart, onConfirm: () => _onConfirmOrder(cart)),
            ],
          ),
        ),
      ),
    );
  }

  /// الأبار فيه عدد القطع وزرار مسح السلة، وبيتحدث مع السلة
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [_buildClearCartAction()],
      title: BlocBuilder<CartCubit, BaseState<CartModel>>(
        bloc: _cartCubit,
        builder: (context, state) {
          final pieces = state.data?.totalPieces ?? 0;

          return Text(
            pieces == 0
                ? 'your_order'.tr()
                : '${'your_order'.tr()} ($pieces ${'piece'.tr()})',
            style: TextStyles.darkBold18,
          );
        },
      ),
    );
  }

  /// بيظهر بس لو السلة فيها حاجة، وبيتبدل بلودينج وقت المسح
  Widget _buildClearCartAction() {
    return BlocBuilder<CartCubit, BaseState<CartModel>>(
      bloc: _cartCubit,
      builder: (context, state) {
        if (state.data?.isEmpty ?? true) return const SizedBox.shrink();

        if (_cartCubit.isClearing) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SizedBox(
              width: 18.r,
              height: 18.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.redColor2,
              ),
            ),
          );
        }

        return IconButton(
          onPressed: _confirmClearCart,
          tooltip: 'clear_cart'.tr(),
          icon: Icon(
            Icons.delete_sweep_outlined,
            size: 22.r,
            color: AppColors.redColor2,
          ),
        );
      },
    );
  }

  /// اسم المغسلة فوق اللستة عشان يعرف الطلب رايح لمين
  Widget _buildLaundryBanner(String laundryName) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_laundry_service_outlined,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              laundryName,
              style: TextStyles.darkBold14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(CartModel cart) {
    return ListView.separated(
      // عشان السحب للتحديث يشتغل حتى لو اللستة قصيرة
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      // بانر المغسلة بيتحسب كأول عنصر في اللستة عشان يتسكرول معاها
      itemCount: cart.items.length + 1,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        if (index == 0) return _buildLaundryBanner(cart.laundryName);
        final item = cart.items[index - 1];
        return CartItemTile(
          item: item,
          boxed: true,
          isUpdating: _cartCubit.isUpdating(item),
          onQuantityChanged: (quantity) =>
              _cartCubit.updateQuantity(item, quantity),
          onRemove: () => _cartCubit.removeItem(item),
        );
      },
    );
  }
}
