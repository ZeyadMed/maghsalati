import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/orders/presentation/view_model/active_orders_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';

/// شريط صغير تحت الرئيسية زي بريستو: اسم المغسلة وحالة الطلب الشغال،
/// والدوس عليه بيفتح تفاصيل الطلب. بيختفي لو مفيش طلبات شغالة.
/// لو فيه أكتر من طلب بيعرض اللي مستني العميل الأول، وإلا الأحدث، وجنبه عدد الباقي.
/// الرئيسية عايشة في IndexedStack، فالشريط بيفضل سامع لتحديثات الطلبات طول الوقت
class ActiveOrderBar extends StatefulWidget {
  const ActiveOrderBar({super.key});

  @override
  State<ActiveOrderBar> createState() => _ActiveOrderBarState();
}

class _ActiveOrderBarState extends State<ActiveOrderBar>
    with WidgetsBindingObserver {
  final ActiveOrdersCubit _cubit = getIt<ActiveOrdersCubit>();
  late final StreamSubscription<int?> _updatesSubscription;
  late final StreamSubscription<OrderModel> _ordersSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit.load();
    // طلب جديد أو أكشن أو إشعار أو reconnect: بنجيب الطلبات تاني
    _updatesSubscription = getIt<OrderUpdates>().stream.listen(
      (_) => _cubit.load(),
    );
    // الطلب كله جاي من الـ realtime، فبيتبدل من غير ريكوست
    _ordersSubscription = getIt<OrderUpdates>().orders.listen(
      _cubit.applyOrder,
    );
  }

  /// الحالة ممكن تكون اتغيرت واليوزر بره التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cubit.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updatesSubscription.cancel();
    _ordersSubscription.cancel();
    _cubit.close();
    super.dispose();
  }

  /// الطلب مستني العميل: دفع مستحق أو تعديل أو المندوب عند الباب
  static bool _needsAction(OrderModel order) =>
      order.needsPayment ||
      order.status == OrderStatus.adjustmentPendingApproval ||
      order.isDriverAtDoor;

  /// اللي مستني العميل الأول، وإلا الأحدث
  OrderModel _featured(List<OrderModel> orders) {
    for (final order in orders) {
      if (_needsAction(order)) return order;
    }
    return orders.reduce((a, b) => b.date.isAfter(a.date) ? b : a);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveOrdersCubit, List<OrderModel>>(
      bloc: _cubit,
      builder: (context, orders) => AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.bottomCenter,
        child: orders.isEmpty
            ? const SizedBox(width: double.infinity)
            : _buildBar(_featured(orders), orders.length - 1),
      ),
    );
  }

  Widget _buildBar(OrderModel order, int othersCount) {
    final needsAction = _needsAction(order);

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 8.h),
      child: Material(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 3,
        shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          // الدفع المستحق بيفتح شيته على طول
          onTap: () => context.push(
            AppRouter.orderDetails,
            extra: OrderDetailsArgs.fromOrder(
              order,
              openPayment: order.needsPayment,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                _buildIcon(needsAction),
                Gap(10.w),
                Expanded(child: _buildTexts(order)),
                if (othersCount > 0) ...[
                  Gap(8.w),
                  _buildOthersCount(othersCount),
                ],
                Gap(6.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.r,
                  color: AppColors.whiteColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// أيقونة غسالة، ولو الطلب مستني العميل عليها نقطة برتقاني تلفت نظره
  Widget _buildIcon(bool needsAction) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38.r,
          height: 38.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_laundry_service_rounded,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
        ),
        if (needsAction)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Container(
              width: 11.r,
              height: 11.r,
              decoration: BoxDecoration(
                color: AppColors.orangeColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  /// اسم المغسلة فوق وحالة الطلب تحته، كل واحد في سطر عشان أسماء المراحل
  /// الطويلة ماتقطعش اسم المغسلة
  Widget _buildTexts(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          order.laundryName.isNotEmpty ? order.laundryName : order.reference,
          style: TextStyles.whiteBold15.copyWith(fontSize: 14.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap(1.h),
        // المستحق بيتقال بدل اسم المرحلة، لأنه اللي واقف عليه الطلب
        Text(
          order.needsPayment
              ? '${order.payActionKey.tr()} • '
                    '${formatOrderPrice(order.amountDue)} ${'currency'.tr()}'
              : order.statusLabelKey.tr(),
          style: TextStyles.darkRegular12.copyWith(
            color: AppColors.whiteColor.withValues(alpha: 0.85),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// "+2": فيه طلبات شغالة تانية، تفاصيلها في تاب الطلبات
  Widget _buildOthersCount(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '+$count',
        style: TextStyles.darkBold12.copyWith(color: AppColors.whiteColor),
      ),
    );
  }
}
