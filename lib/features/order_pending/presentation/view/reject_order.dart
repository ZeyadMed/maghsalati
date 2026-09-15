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

/// شاشة رفض الطلب، بتتفتح لما المغسلة ترفض الطلب
/// قدام المستخدم اختيارين: يحاول تاني بنفس الطلب أو يختار مغسلة تانية
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
                      label: 'try_again'.tr(),
                      filled: true,
                      onPressed: () => _retry(context),
                    ),
                    Gap(12.h),
                    OrderActionButton(
                      label: 'choose_another_laundry'.tr(),
                      onPressed: () => _chooseAnotherLaundry(context),
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

  /// بيبعت نفس الطلب تاني ويرجع لشاشة الانتظار
  /// TODO: اعمل resend للطلب على ال endpoint هنا الأول لما يجهز
  void _retry(BuildContext context) {
    context.pushReplacement(AppRouter.orderPending, extra: order);
  }

  /// بيرجع للرئيسية عشان يختار مغسلة تانية
  void _chooseAnotherLaundry(BuildContext context) {
    context.go(AppRouter.initialRoot);
  }
}
