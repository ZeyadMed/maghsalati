import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';

/// كارت بيانات العميل: اسمه ورقمه، واللي هيسلّم الهدوم لو حد تاني،
/// وعنوان الاستلام والتوصيل (نفس العنوان للاتنين).
/// لو السيرفر مابعتش اسم العميل أو رقمه بناخدهم من البروفايل المتخزن
class OrderCustomerCard extends StatelessWidget {
  final OrderModel order;

  const OrderCustomerCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final name = order.customerName.isNotEmpty
        ? order.customerName
        : CacheManager.getUserName() ?? '';
    final phone = order.customerPhone.isNotEmpty
        ? order.customerPhone
        : CacheManager.getUserPhone() ?? '';
    final handover = _handoverContact(name, phone);

    final rows = [
      if (name.isNotEmpty)
        OrderInfoRow(
          icon: Icons.person_outline_rounded,
          label: 'customer_name'.tr(),
          value: name,
        ),
      if (phone.isNotEmpty)
        OrderInfoRow(
          icon: Icons.phone_outlined,
          label: 'phone_number'.tr(),
          value: phone,
        ),
      if (handover.isNotEmpty)
        OrderInfoRow(
          icon: Icons.people_outline_rounded,
          label: 'pickup_contact'.tr(),
          value: handover,
        ),
      if (order.deliveryAddress.isNotEmpty)
        OrderInfoRow(
          icon: Icons.location_on_outlined,
          label: 'pickup_delivery_address'.tr(),
          value: order.deliveryAddress,
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return OrderSectionCard(
      title: 'customer_info'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) ...[
              Gap(10.h),
              Divider(height: 1.h, color: AppColors.lightGreyColor),
              Gap(10.h),
            ],
            rows[i],
          ],
        ],
      ),
    );
  }

  /// المُسلِّم بيتبعت مع كل طلب (متعبي من البروفايل)، فبيتعرض بس لو مختلف
  /// عن العميل نفسه: "الاسم • الرقم"
  String _handoverContact(String customerName, String customerPhone) {
    final contactName = order.pickupContactName.trim();
    final contactPhone = order.pickupContactPhone.trim();
    final differs =
        (contactName.isNotEmpty && contactName != customerName.trim()) ||
        (contactPhone.isNotEmpty && !_samePhone(contactPhone, customerPhone));
    if (!differs) return '';
    return [contactName, contactPhone].where((s) => s.isNotEmpty).join(' • ');
  }

  /// نفس الرقم حتى لو واحد بكود الدولة والتاني من غيره (آخر 9 أرقام)
  static bool _samePhone(String a, String b) {
    String tail(String phone) {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      return digits.length > 9 ? digits.substring(digits.length - 9) : digits;
    }

    return tail(a) == tail(b);
  }
}
