import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/loading_shimmer.dart';
import 'package:maghsalati/features/laundry_details/data/model/working_hours_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/working_hours_cubit.dart';

/// ديالوج بيجيب مواعيد عمل المغسلة من ال endpoint ويعرضها
/// بيظهر لما المستخدم يدوس على مغسلة مقفولة، أو من زرار المواعيد في التفاصيل
class WorkingHoursDialog extends StatefulWidget {
  final int laundryId;
  final String laundryName;

  const WorkingHoursDialog({
    super.key,
    required this.laundryId,
    required this.laundryName,
  });

  /// بيفتح الديالوج، بيرجع Future تخلص لما يتقفل
  static Future<void> show(
    BuildContext context, {
    required int laundryId,
    required String laundryName,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          WorkingHoursDialog(laundryId: laundryId, laundryName: laundryName),
    );
  }

  @override
  State<WorkingHoursDialog> createState() => _WorkingHoursDialogState();
}

class _WorkingHoursDialogState extends State<WorkingHoursDialog> {
  final WorkingHoursCubit _cubit = getIt<WorkingHoursCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getWorkingHours(widget.laundryId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
      title: _buildTitle(),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<WorkingHoursCubit, BaseState<WorkingHoursModel>>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.isInitial || state.isLoading) return _buildLoading();
            if (state.isFailure || state.data == null) {
              return _buildFailure(state.errorMessage);
            }
            return _buildContent(context, state.data!);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'close'.tr(),
            style: TextStyles.darkBold14.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WorkingHoursModel hours) {
    final locale = context.locale.toString();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // التنبيه بيظهر بس لو المغسلة مقفولة فعلاً دلوقتي
        if (!hours.isAvailableNow) ...[
          _buildClosedNote(),
          SizedBox(height: 16.h),
        ],
        if (hours.days.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: LocalizedLabel(
              text: 'no_working_hours',
              style: TextStyles.greyColor2Regular14,
              textAlign: TextAlign.center,
            ),
          ),
        for (final day in hours.days) _buildDayRow(day, locale),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: ShimmerBox(
              height: 18.h,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
      ],
    );
  }

  Widget _buildFailure(String? message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 40.r, color: AppColors.greyColor5),
        SizedBox(height: 8.h),
        LocalizedLabel(
          text: message ?? 'try_again',
          style: TextStyles.darkRegular14,
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: () => _cubit.getWorkingHours(widget.laundryId),
          child: LocalizedLabel(
            text: 'try_again',
            style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 22.r,
          color: AppColors.primaryColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'working_hours'.tr(),
                style: TextStyles.darkBold16.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.laundryName,
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// تنبيه إن المغسلة مقفولة دلوقتي
  Widget _buildClosedNote() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.redColor2.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18.r, color: AppColors.redColor2),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'laundry_closed_note'.tr(),
              style: TextStyles.darkRegular12.copyWith(
                color: AppColors.redColor2,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(WorkingDayModel day, String locale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day.dayKey.tr(),
              style: TextStyles.darkRegular14.copyWith(
                color: AppColors.darkTextColor,
              ),
            ),
          ),
          Text(
            day.isOff ? 'closed'.tr() : day.formattedRange(locale),
            style: TextStyles.boldStyle(
              13,
              color: day.isOff ? AppColors.redColor2 : AppColors.primaryColor,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
