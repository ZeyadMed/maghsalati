import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// "4 ساعات" أو "يومان" أو "يوم و 3 ساعات" من عدد الدقايق
String formatPreparationDuration(int minutes) {
  final days = minutes ~/ 1440;
  final hours = (minutes % 1440) ~/ 60;
  final mins = minutes % 60;
  final parts = [
    if (days > 0) 'days_count'.plural(days),
    if (hours > 0) 'hours_count'.plural(hours),
    if (mins > 0) 'minutes_count'.plural(mins),
  ];
  if (parts.isEmpty) return 'minutes_count'.plural(0);
  return parts.join(' ${'and_separator'.tr()} ');
}

/// العدّاد: "02:15:40"، ولو فاضل أكتر من يوم "يومان 03:20"
String formatCountdown(Duration duration) {
  final value = duration.isNegative ? -duration : duration;
  String two(int n) => n.toString().padLeft(2, '0');
  final days = value.inDays;
  final hours = two(value.inHours % 24);
  final minutes = two(value.inMinutes % 60);
  if (days > 0) return '${'days_count'.plural(days)} $hours:$minutes';
  return '$hours:$minutes:${two(value.inSeconds % 60)}';
}

/// "اليوم 4:30 م" أو "غداً 10:00 ص" أو "15 نوفمبر 9:00 ص" بالتوقيت المحلي
String formatReadyAt(DateTime utc, String locale) {
  final local = utc.toLocal();
  final now = DateTime.now();
  final day = DateTime(local.year, local.month, local.day);
  final diff = day.difference(DateTime(now.year, now.month, now.day)).inDays;
  final dayText = switch (diff) {
    0 => 'today'.tr(),
    1 => 'tomorrow'.tr(),
    _ => DateFormat('d MMMM', locale).format(local),
  };
  return '$dayText ${DateFormat('h:mm a', locale).format(local)}';
}

/// سطر موعد الجاهزية في كارت الطلب وتفاصيله:
/// - بعد القبول وقبل الاستلام: "هيجهز خلال 4 ساعات من الاستلام"
/// - بعد الاستلام: "جاهز اليوم 4:30 م" وجنبه عدّاد تنازلي، وبيقلب أحمر لو اتأخر
/// وبعد ما الطلب يجهز (أو قبل القبول) مش بيظهر خالص
class OrderReadyTime extends StatelessWidget {
  final OrderModel order;

  const OrderReadyTime({super.key, required this.order});

  /// الطلب عنده حاجة يعرضها، عشان الكروت تشيل المسافات لو مفيش
  static bool isVisibleFor(OrderModel order) =>
      order.isPreparing || order.showsPreparationDuration;

  @override
  Widget build(BuildContext context) {
    final readyAt = order.promisedReadyAt;
    if (order.isPreparing && readyAt != null) {
      return CountdownBuilder(
        target: readyAt,
        builder: (context, remaining) {
          final isLate = remaining.isNegative;
          return _ReadyTimeRow(
            icon: Icons.timer_outlined,
            color: isLate ? AppColors.redColor2 : AppColors.primaryColor,
            text: 'ready_by'.tr(
              args: [formatReadyAt(readyAt, context.locale.toString())],
            ),
            trailing: (isLate ? 'overdue_by' : 'ready_in').tr(
              args: [formatCountdown(remaining)],
            ),
          );
        },
      );
    }
    final minutes = order.preparationDurationMinutes;
    if (order.showsPreparationDuration && minutes != null) {
      return _ReadyTimeRow(
        icon: Icons.hourglass_bottom_rounded,
        color: AppColors.primaryColor,
        text: 'ready_within_after_receipt'.tr(
          args: [formatPreparationDuration(minutes)],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ReadyTimeRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? trailing;

  const _ReadyTimeRow({
    required this.icon,
    required this.color,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: color),
          Gap(8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyles.darkRegular12.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...[
            Gap(8.w),
            Text(
              trailing!,
              maxLines: 1,
              style: TextStyles.darkBold16.copyWith(
                fontSize: 13.sp,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// بيبني الـ child كل ثانية بالوقت الفاضل لحد [target]،
/// وبيبقى بالسالب لما الموعد يعدّي
class CountdownBuilder extends StatefulWidget {
  final DateTime target;
  final Widget Function(BuildContext context, Duration remaining) builder;

  const CountdownBuilder({
    super.key,
    required this.target,
    required this.builder,
  });

  @override
  State<CountdownBuilder> createState() => _CountdownBuilderState();
}

class _CountdownBuilderState extends State<CountdownBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.target.difference(DateTime.now().toUtc()));
}
