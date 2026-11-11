import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/driver_plate_badge.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/phone_call.dart';

/// كارت مندوب رحلة واحدة (الاستلام أو التسليم): فوق نوع الرحلة وحالتها في
/// شارة ملونة، وتحتهم أيقونة واسم المندوب ورقمه وزرار اتصال مدوّر.
/// الرحلة اللي المندوب شغال عليها دلوقتي لونها أزرق فاتح عشان تبان،
/// واللي خلصت أو لسه مستنية مندوب رمادي.
/// تحت الاسم لوحة المركبة، وتحتها شريط فيه التقييم وإجمالي الرحلات ومدة الشغل،
/// وأي حاجة منهم السيرفر مابعتهاش بتستخبى.
/// في الآخر زرار "قيّم المندوب" لو [onRate] موجود (الرحلة خلصت ولسه
/// ماتقيّمتش)، أو "تم تقييم المندوب" لو [isRated]
class OrderDriverTile extends StatelessWidget {
  final OrderTripModel trip;
  final DriverTripStage stage;
  final VoidCallback? onRate;
  final bool isRated;

  const OrderDriverTile({
    super.key,
    required this.trip,
    required this.stage,
    this.onRate,
    this.isRated = false,
  });

  bool get _isPickup => trip.type == DeliveryTripType.pickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: stage.isActive
            ? AppColors.primaryColor.withValues(alpha: 0.08)
            : AppColors.greyColor5.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          if (trip.driverPlateNumber.isNotEmpty) ...[
            Gap(10.h),
            _buildPlate(),
          ],
          if (trip.hasDriverStats) ...[Gap(10.h), _buildStats()],
          if (onRate != null) ...[
            Gap(10.h),
            _buildRateButton(),
          ] else if (isRated) ...[
            Gap(10.h),
            _buildRated(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final (_, stageColor) = _stageStyle();

    return Row(
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            stage == DriverTripStage.awaitingDriver
                ? Icons.hourglass_top_rounded
                : Icons.delivery_dining_rounded,
            size: 26.r,
            color: stageColor,
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      (_isPickup ? 'pickup_driver' : 'dropoff_driver').tr(),
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap(6.w),
                  _buildStageChip(),
                ],
              ),
              Gap(4.h),
              if (trip.hasDriver) ...[
                Text(
                  trip.driverName.isNotEmpty
                      ? trip.driverName
                      : trip.driverPhone,
                  style: TextStyles.darkBold14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (trip.driverName.isNotEmpty && trip.driverPhone.isNotEmpty)
                  Text(
                    trip.driverPhone,
                    style: TextStyles.darkRegular12.copyWith(
                      color: AppColors.greyColor3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ] else
                Text(
                  'driver_awaiting_assignment_desc'.tr(),
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor3,
                  ),
                ),
            ],
          ),
        ),
        if (trip.driverPhone.isNotEmpty) ...[
          Gap(8.w),
          _buildCallButton(context),
        ],
      ],
    );
  }

  /// شارة حالة الرحلة بلونها
  Widget _buildStageChip() {
    final (labelKey, color) = _stageStyle();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        labelKey.tr(),
        style: TextStyles.darkBold14.copyWith(fontSize: 11.sp, color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// مفتاح ترجمة الحالة ولونها. الخلصانة والفاشلة نصها مختلف للاستلام والتسليم
  (String, Color) _stageStyle() => switch (stage) {
    DriverTripStage.awaitingDriver => (
      'driver_stage_awaiting',
      AppColors.greyColor3,
    ),
    DriverTripStage.onTheWay => (
      'driver_stage_on_the_way',
      AppColors.primaryColor,
    ),
    DriverTripStage.arrived => ('driver_stage_arrived', AppColors.orangeColor),
    DriverTripStage.toLaundry => (
      'driver_stage_to_laundry',
      AppColors.primaryColor,
    ),
    DriverTripStage.atLaundry => (
      'driver_stage_at_laundry',
      AppColors.primaryColor,
    ),
    DriverTripStage.completed => (
      _isPickup ? 'driver_stage_picked_up' : 'driver_stage_delivered',
      AppColors.greenColor,
    ),
    DriverTripStage.failed => (
      _isPickup ? 'driver_stage_pickup_failed' : 'driver_stage_delivery_failed',
      AppColors.redColor2,
    ),
    DriverTripStage.cancelled => (
      'driver_stage_cancelled',
      AppColors.greyColor3,
    ),
  };

  Widget _buildPlate() {
    return Row(
      children: [
        Icon(
          Icons.directions_car_rounded,
          size: 18.r,
          color: AppColors.greyColor3,
        ),
        Gap(6.w),
        Expanded(
          child: Text(
            'driver_plate_number'.tr(),
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.greyColor3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(8.w),
        DriverPlateBadge(plateNumber: trip.driverPlateNumber),
      ],
    );
  }

  Widget _buildRateButton() {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onRate,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 20.r,
                color: AppColors.lightOrangeColor,
              ),
              Gap(6.w),
              Text(
                'rate_driver'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRated() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 16.r,
          color: AppColors.greenColor,
        ),
        Gap(6.w),
        Text(
          'driver_reviewed'.tr(),
          style: TextStyles.darkRegular12.copyWith(color: AppColors.greenColor),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final months = trip.driverMonthsOfService;
    final stats = [
      if (trip.hasDriverRating)
        _DriverStat(
          icon: Icons.star_rounded,
          iconColor: AppColors.orangeColor,
          value: trip.isNewDriver
              ? 'driver_new'.tr()
              : (trip.driverRating ?? 0).toStringAsFixed(1),
          label: 'driver_rating'.tr(),
        ),
      if (trip.driverTotalTrips != null)
        _DriverStat(
          icon: Icons.route_rounded,
          iconColor: AppColors.primaryColor,
          value: '${trip.driverTotalTrips}',
          label: 'driver_total_trips'.tr(),
        ),
      if (months != null)
        _DriverStat(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.greenColor,
          value: _workDuration(months),
          label: 'driver_work_duration'.tr(),
        ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.greyColor3.withValues(alpha: 0.2),
                ),
              Expanded(child: stats[i]),
            ],
          ],
        ),
      ),
    );
  }

  /// "أقل من شهر" أو "5 شهور" أو "سنتين" بصيغة الجمع الصح لكل لغة
  static String _workDuration(int months) {
    if (months < 1) return 'driver_duration_less_than_month'.tr();
    if (months < 12) return 'driver_duration_months'.plural(months);
    return 'driver_duration_years'.plural(months ~/ 12);
  }

  Widget _buildCallButton(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => callPhone(context, trip.driverPhone),
        child: SizedBox.square(
          dimension: 42.r,
          child: Icon(
            Icons.call_rounded,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

/// خانة واحدة في شريط الإحصائيات: أيقونة وقيمة، وتحتهم اسمها
class _DriverStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _DriverStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.r, color: iconColor),
              Gap(4.w),
              Flexible(
                child: Text(
                  value,
                  style: TextStyles.darkBold14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Gap(2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.greyColor3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
