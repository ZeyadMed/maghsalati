import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_action_button.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/rejected_status_header.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';

/// شاشة رفض الطلب، بتتفتح من شاشة الانتظار لما المغسلة ترفض
/// السلة اتفضت وقت التأكيد، فمفيش "إعادة إرسال" لنفس الطلب:
/// يا يختار مغسلة تانية، يا يشوف تفاصيل الطلب المرفوض (فيها سبب الرفض لو موجود)
class RejectOrder extends StatelessWidget {
  final PendingOrderModel order;

  const RejectOrder({super.key, required this.order});

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
                    RejectedStatusHeader(laundryName: order.laundryName),
                    Gap(28.h),
                    OrderActionButton(
                      label: 'choose_another_laundry'.tr(),
                      filled: true,
                      onPressed: () => context.go(AppRouter.initialRoot),
                    ),
                    if (order.hasOrderId) ...[
                      Gap(12.h),
                      OrderActionButton(
                        label: 'view_details'.tr(),
                        onPressed: () => _openDetails(context),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    context.pushReplacement(
      AppRouter.orderDetails,
      extra: OrderDetailsArgs(orderId: order.orderId),
    );
  }
}
