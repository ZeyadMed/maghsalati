import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_state_view.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/checkout_form.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// الطلب اللي اتأكد، ومعاه السلة زي ما كانت وقت التأكيد (لشاشة الانتظار)
typedef ConfirmedCart = ({OrderModel order, CartModel cart});

/// شيت تأكيد الطلب من المغسلة: نفس تفاصيل الطلب اللي في تاب السلة
/// ([CheckoutForm]) جوه شيت. السلة من [CartCubit] المشترك، فلو العنوان أو
/// الكميات اتغيرت جوه الشيت الأسعار بتتحدث على طول
class ConfirmCartBottomSheet extends StatelessWidget {
  const ConfirmCartBottomSheet({super.key});

  /// بيرجع الطلب لو اتأكد من السيرفر: بالمحفظة بيبقى New ومدفوع، وبالبوابة
  /// PendingPayment ومعاه paymentUrl لسه هيتفتح. و null لو قفل من غير تأكيد
  static Future<ConfirmedCart?> show(BuildContext context) {
    return showModalBottomSheet<ConfirmedCart>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ConfirmCartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // الشيت بيطلع فوق الكيبورد عشان الخانات ماتستخباش
      padding: EdgeInsets.only(bottom: context.keyboardHeight),
      child: Container(
        constraints: BoxConstraints(maxHeight: context.screenHeight * 0.9),
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
                  cubit: getIt<CartCubit>(),
                  builder: (context, cart) => CheckoutForm(
                    cart: cart,
                    onConfirmed: (order, cart) =>
                        Navigator.of(context)
                            .pop<ConfirmedCart>((order: order, cart: cart)),
                  ),
                ),
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
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 2.h, 8.w, 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text('order_details'.tr(), style: TextStyles.darkBold18),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.close, size: 20.r, color: AppColors.greyColor2),
          ),
        ],
      ),
    );
  }
}
