import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// مراحل الطلب اللي تنطبق على طريقة التسليم ([OrderModel.stages]).
/// المراحل كتير على سطر واحد، فليها شكلين:
/// - مختصر (كارت الطلب في الليستة): شريط مقسوم بعدد المراحل وتحته رقم المرحلة
///   والمرحلة الجاية، واسم المرحلة الحالية في شارة الكارت
/// - كامل ([showAllStages]، شاشة التفاصيل): المراحل تحت بعض بأسمائها
/// المرفوض والملغي مالهمش مراحل فمش بيترسم حاجة
class OrderProgressTracker extends StatelessWidget {
  final OrderModel order;
  final bool showAllStages;

  const OrderProgressTracker({
    super.key,
    required this.order,
    this.showAllStages = false,
  });

  @override
  Widget build(BuildContext context) {
    final current = order.currentStage;
    if (current == null) return const SizedBox.shrink();

    final stages = order.stages;
    final currentIndex = stages.indexOf(current);
    return showAllStages
        ? _buildTimeline(stages, currentIndex)
        : _buildBar(stages, currentIndex);
  }

  /// آخر مرحلة (مكتمل) لما الطلب يوصلها بتتحسب خلصت مش شغالة
  bool _isDone(int index, int currentIndex, int count) =>
      index < currentIndex || (index == currentIndex && index == count - 1);

  Color get _activeColor =>
      order.isStageFailed ? AppColors.redColor2 : AppColors.primaryColor;

  // ---------- المختصر ----------

  Widget _buildBar(List<OrderStage> stages, int currentIndex) {
    final next = currentIndex + 1 < stages.length
        ? stages[currentIndex + 1]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (int i = 0; i < stages.length; i++) ...[
              if (i > 0) Gap(4.w),
              Expanded(
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: i <= currentIndex
                        ? (i == currentIndex
                              ? _activeColor
                              : AppColors.primaryColor)
                        : AppColors.semiWhiteColor2,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ],
          ],
        ),
        Gap(8.h),
        Row(
          children: [
            Text(
              'stage_progress'.tr(
                args: ['${currentIndex + 1}', '${stages.length}'],
              ),
              style: TextStyles.darkRegular12.copyWith(
                color: AppColors.greyColor3,
              ),
            ),
            if (next != null) ...[
              Gap(12.w),
              Expanded(
                child: Text(
                  'stage_next'.tr(args: [order.stageLabelKey(next).tr()]),
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor3,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ---------- الكامل ----------

  /// كل مرحلة: دايرة وتحتها خط لحد اللي بعدها، واسمها جنبها
  Widget _buildTimeline(List<OrderStage> stages, int currentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < stages.length; i++)
          _buildTimelineRow(stages, i, currentIndex),
      ],
    );
  }

  Widget _buildTimelineRow(
    List<OrderStage> stages,
    int index,
    int currentIndex,
  ) {
    final isDone = _isDone(index, currentIndex, stages.length);
    final isCurrent = index == currentIndex && !isDone;
    final isLast = index == stages.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildCircle(stages[index], isDone: isDone, isCurrent: isCurrent),
            if (!isLast)
              Container(
                width: 2,
                height: 16.h,
                color: index < currentIndex
                    ? AppColors.primaryColor
                    : AppColors.semiWhiteColor2,
              ),
          ],
        ),
        Gap(12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              order.stageLabelKey(stages[index]).tr(),
              style: isCurrent
                  ? TextStyles.darkBold14.copyWith(color: _activeColor)
                  : TextStyles.darkRegular14.copyWith(
                      color: isDone
                          ? AppColors.greyColor2
                          : AppColors.greyColor4,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// اللي خلصت: صح أبيض على أزرق، والحالية: أيقونتها بإطار، والجاية: رمادي
  Widget _buildCircle(
    OrderStage stage, {
    required bool isDone,
    required bool isCurrent,
  }) {
    final Color background;
    final Color border;
    final Color iconColor;
    if (isDone) {
      background = AppColors.primaryColor;
      border = AppColors.primaryColor;
      iconColor = AppColors.whiteColor;
    } else if (isCurrent) {
      background = _activeColor.withValues(alpha: 0.12);
      border = _activeColor;
      iconColor = _activeColor;
    } else {
      background = AppColors.whiteColor;
      border = AppColors.semiWhiteColor2;
      iconColor = AppColors.greyColor4;
    }

    return Container(
      width: 26.r,
      height: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.5),
      ),
      child: Icon(
        isDone
            ? Icons.check_rounded
            : (isCurrent && order.isStageFailed
                  ? Icons.priority_high_rounded
                  : _iconFor(stage)),
        size: 15.r,
        color: iconColor,
      ),
    );
  }

  IconData _iconFor(OrderStage stage) => switch (stage) {
    OrderStage.pending => Icons.hourglass_top_rounded,
    OrderStage.accepted => Icons.thumb_up_alt_outlined,
    OrderStage.awaitingHandover =>
      order.customerDropsOff
          ? Icons.storefront_outlined
          : Icons.local_shipping_outlined,
    OrderStage.received => Icons.fact_check_outlined,
    OrderStage.inProgress => Icons.local_laundry_service_outlined,
    OrderStage.ready => Icons.inventory_2_outlined,
    OrderStage.onTheWay => Icons.delivery_dining_outlined,
    OrderStage.delivered => Icons.home_outlined,
    OrderStage.completed => Icons.verified_outlined,
  };
}
