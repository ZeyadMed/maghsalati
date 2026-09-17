import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// شريط خطوات الطلب: الخطوات الخالصة بعلامة صح زرقا واللي لسه برقمها ورمادي
/// الترتيب من تم الإرسال لحد تم التسليم، والاتجاه بيتظبط لوحده حسب اللغة
class OrderProgressTracker extends StatelessWidget {
  final OrderStatus status;

  /// نفس ترتيب الحالات في الـ enum، دي الخطوات اللي بتتعرض في الشريط
  static const List<OrderStatus> _steps = [
    OrderStatus.sent,
    OrderStatus.washing,
    OrderStatus.ready,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  const OrderProgressTracker({super.key, required this.status});

  /// رقم الخطوة الحالية، و -1 لو الحالة مش من خطوات الشريط (زي الملغي)
  int get _currentIndex => _steps.indexOf(status);

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (index) {
        // الفردي بينهم خطوط واصلة والزوجي دواير الخطوات
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          return Expanded(child: _buildConnector(stepIndex < currentIndex));
        }
        final stepIndex = index ~/ 2;
        return _buildStep(stepIndex, currentIndex);
      }),
    );
  }

  /// الخط اللي بين كل دايرتين، بيتلون أزرق لو الخطوة اللي قبله خلصت
  Widget _buildConnector(bool isDone) {
    return Padding(
      // بيتحط في نص ارتفاع الدايرة عشان يبان واصل بينهم
      padding: EdgeInsets.only(top: 13.h),
      child: Container(
        height: 2.h,
        color: isDone ? AppColors.primaryColor : AppColors.semiWhiteColor2,
      ),
    );
  }

  /// الدايرة + اسم الخطوة تحتها
  Widget _buildStep(int stepIndex, int currentIndex) {
    final step = _steps[stepIndex];
    final isDone = stepIndex <= currentIndex;
    final isCurrent = stepIndex == currentIndex;

    return SizedBox(
      width: 56.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircle(stepIndex, isDone),
          Gap(6.h),
          Text(
            step.labelKey.tr(),
            textAlign: TextAlign.center,
            style: TextStyles.darkRegular12.copyWith(
              fontSize: 10.sp,
              // الخطوة الحالية بتبان أوضح من اللي حواليها
              color: isCurrent
                  ? AppColors.primaryColor
                  : AppColors.greyColor3,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// دايرة زرقا بعلامة صح للخطوة اللي خلصت، ورمادية برقمها للي لسه
  Widget _buildCircle(int stepIndex, bool isDone) {
    return Container(
      width: 26.r,
      height: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primaryColor : AppColors.whiteColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? AppColors.primaryColor : AppColors.semiWhiteColor2,
          width: 1.5,
        ),
      ),
      child: isDone
          ? Icon(Icons.check, size: 14.r, color: AppColors.whiteColor)
          : Text(
              '${stepIndex + 1}',
              style: TextStyles.darkBold12.copyWith(
                fontSize: 11.sp,
                color: AppColors.greyColor3,
              ),
            ),
    );
  }
}
