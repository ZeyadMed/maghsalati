import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/accepted_status_header.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_action_button.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_details_card.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';

/// شاشة قبول الطلب، بتتفتح لوحدها من شاشة الانتظار لما المغسلة توافق
/// نفس تنسيق شاشة الانتظار بس بعلامة الصح، وتحتها متابعة الطلب أو الرجوع للرئيسية
class ConfirmOrder extends StatelessWidget {
  final PendingOrderModel order;

  const ConfirmOrder({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              // المحتوى بيتوسط رأسيًا، ولو طول عن الشاشة بيسكرول عادي
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AcceptedStatusHeader(laundryName: order.laundryName),
                    Gap(28.h),
                    OrderDetailsCard(order: order, showTitle: false),
                    Gap(28.h),
                    if (order.hasOrderId) ...[
                      OrderActionButton(
                        label: 'follow_order'.tr(),
                        filled: true,
                        onPressed: () => _followOrder(context),
                      ),
                      Gap(12.h),
                    ],
                    OrderActionButton(
                      label: 'back_to_home'.tr(),
                      onPressed: () => context.go(AppRouter.initialRoot),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// replacement عشان الرجوع من التفاصيل مايرجعش لشاشة القبول تاني
  void _followOrder(BuildContext context) {
    context.pushReplacement(
      AppRouter.orderDetails,
      extra: OrderDetailsArgs(orderId: order.orderId),
    );
  }
}
