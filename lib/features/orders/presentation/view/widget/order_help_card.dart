import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/phone_call.dart';

/// آخر الشاشة: الاتصال بالمغسلة (لو رقمها موجود) والدعم والمساعدة.
/// الاتصال بالمندوب في كارت التتبع جنب بياناته
class OrderHelpCard extends StatelessWidget {
  final OrderModel order;

  const OrderHelpCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return OrderSectionCard(
      title: 'order_need_help'.tr(),
      child: Row(
        children: [
          if (order.laundryPhone.isNotEmpty) ...[
            Expanded(
              child: SheetButton(
                label: 'call_laundry'.tr(),
                filled: false,
                onPressed: () => callPhone(context, order.laundryPhone),
              ),
            ),
            Gap(10.w),
          ],
          Expanded(
            child: SheetButton(
              label: 'contact_support'.tr(),
              filled: false,
              onPressed: () => context.push(AppRouter.contactUsScreen),
            ),
          ),
        ],
      ),
    );
  }
}
