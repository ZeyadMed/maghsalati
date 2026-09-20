import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/accepted_status_header.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_action_button.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_details_card.dart';

/// شاشة قبول الطلب، بتتفتح لوحدها بعد ما المغسلة توافق
/// نفس تنسيق شاشة الانتظار بس بعلامة الصح وزرار الرجوع للرئيسية
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
                    _buildBackToHomeButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// بيرجع للرئيسية ويمسح الشاشات اللي قبلها عشان الطلب خلص
  /// والسلة بتتفضى هنا عشان الطلب اتقبل خلاص، فتاب السلة مايفضلش فيه
  /// قطع الطلب اللي اتبعت
  Widget _buildBackToHomeButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: OrderActionButton(
        label: 'back_to_home'.tr(),
        onPressed: () {
          getIt<SelectedServicesController>().clear();
          context.go(AppRouter.initialRoot);
        },
      ),
    );
  }
}
