import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// شريط خطوات الطلب: الخطوات اللي الطلب وصلها أيقونتها زرقا واللي لسه رمادي،
/// والخطوط بينها لازقة في الدواير. الترتيب من جديدة لحد قيد التوصيل،
/// والاتجاه بيتظبط لوحده حسب اللغة
class OrderProgressTracker extends StatelessWidget {
  final OrderStatus status;

  /// الخطوات اللي بتتعرض في الشريط، مش كل الحالات عشان الشريط مايزحمش
  /// والحالات اللي مش هنا بتتحسب على خطوة منهم في [_currentIndex]
  static const List<OrderStatus> _steps = [
    OrderStatus.newOrder,
    OrderStatus.awaitingPickup,
    OrderStatus.inProgress,
    OrderStatus.ready,
    OrderStatus.outForDelivery,
  ];

  const OrderProgressTracker({super.key, required this.status});

  /// رقم الخطوة الحالية، و -1 للمرفوضة والملغية فالشريط بيبان كله رمادي
  int get _currentIndex => switch (status) {
    // المطابقة وموافقة التعديل بيحصلوا في المغسلة قبل الغسيل،
    // فالاستلام خلص وخطوة قيد التنفيذ هي اللي شغالة
    OrderStatus.atLaundryPendingMatch ||
    OrderStatus.adjustmentPendingApproval => _steps.indexOf(
      OrderStatus.inProgress,
    ),
    // الفشل بيفضل على الخطوة اللي وقف عندها، ومستني المندوب يعدي على المغسلة
    // لسه جاهزة من ناحية العميل
    OrderStatus.pickupFailed => _steps.indexOf(OrderStatus.awaitingPickup),
    OrderStatus.awaitingDropoffCollection => _steps.indexOf(OrderStatus.ready),
    OrderStatus.deliveryFailed => _steps.indexOf(OrderStatus.outForDelivery),
    // اتسلم يبقى كل الخطوات خلصت
    OrderStatus.delivered => _steps.length - 1,
    _ => _steps.indexOf(status),
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex;

    // كل الخطوات نفس العرض، والاسم في نص الخطوة تحت الدايرة بالظبط
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _steps.length; i++)
          Expanded(child: _buildStep(i, currentIndex)),
      ],
    );
  }

  /// الدايرة وعلى جنبيها نصين الخط، فالخط بيلزق فيها ويكمل في الخطوة اللي
  /// جنبها من غير فراغ، واسم الخطوة تحتها
  Widget _buildStep(int stepIndex, int currentIndex) {
    final step = _steps[stepIndex];
    final isDone = stepIndex <= currentIndex;
    final isCurrent = stepIndex == currentIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // نص الخط اللي جاي من الخطوة اللي قبلها، أزرق لو وصلنا الخطوة دي
            Expanded(
              child: stepIndex == 0
                  ? const SizedBox.shrink()
                  : _buildConnector(isDone),
            ),
            _buildCircle(stepIndex, isDone),
            // نص الخط اللي رايح للخطوة اللي بعدها، أزرق لو وصلنا اللي بعدها
            Expanded(
              child: stepIndex == _steps.length - 1
                  ? const SizedBox.shrink()
                  : _buildConnector(stepIndex < currentIndex),
            ),
          ],
        ),
        Gap(6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            step.labelKey.tr(),
            textAlign: TextAlign.center,
            style: TextStyles.darkRegular12.copyWith(
              fontSize: 10.sp,
              // الخطوة الحالية بتبان أوضح من اللي حواليها
              color: isCurrent ? AppColors.primaryColor : AppColors.greyColor3,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isDone) {
    return Container(
      height: 2.h,
      color: isDone ? AppColors.primaryColor : AppColors.semiWhiteColor2,
    );
  }

  /// دايرة بأيقونة الخطوة: زرقا للي الطلب وصلها ورمادية للي لسه
  Widget _buildCircle(int stepIndex, bool isDone) {
    final color = isDone ? AppColors.primaryColor : AppColors.greyColor3;
    return Container(
      width: 26.r,
      height: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.primaryColor.withValues(alpha: 0.12)
            : AppColors.whiteColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? AppColors.primaryColor : AppColors.semiWhiteColor2,
          width: 1.5,
        ),
      ),
      child: Icon(_iconFor(_steps[stepIndex]), size: 15.r, color: color),
    );
  }

  IconData _iconFor(OrderStatus step) => switch (step) {
    OrderStatus.newOrder => Icons.receipt_long_outlined,
    OrderStatus.awaitingPickup => Icons.local_shipping_outlined,
    OrderStatus.inProgress => Icons.local_laundry_service_outlined,
    OrderStatus.ready => Icons.inventory_2_outlined,
    OrderStatus.outForDelivery => Icons.delivery_dining_outlined,
    _ => Icons.circle_outlined,
  };
}
