import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// يوم واحد من مواعيد عمل المغسلة
/// لو [from] أو [to] فاضية يبقى اليوم ده أجازة
class WorkingDay {
  /// مفتاح الترجمة لاسم اليوم زي 'saturday'
  final String dayKey;
  final String? from;
  final String? to;

  const WorkingDay({required this.dayKey, this.from, this.to});

  bool get isClosed => from == null || to == null;
}

/// ديالوج بيعرض مواعيد عمل المغسلة، بيظهر لما المستخدم يدوس على مغسلة مقفولة
class WorkingHoursDialog extends StatelessWidget {
  final String laundryName;
  final List<WorkingDay> workingHours;

  const WorkingHoursDialog({
    super.key,
    required this.laundryName,
    required this.workingHours,
  });

  /// بيفتح الديالوج، بيرجع Future تخلص لما يتقفل
  static Future<void> show(
    BuildContext context, {
    required String laundryName,
    required List<WorkingDay> workingHours,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => WorkingHoursDialog(
        laundryName: laundryName,
        workingHours: workingHours,
      ),
    );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClosedNote(),
            SizedBox(height: 16.h),
            for (final day in workingHours) _buildDayRow(day),
          ],
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
                laundryName,
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

  Widget _buildDayRow(WorkingDay day) {
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
            day.isClosed ? 'closed'.tr() : '${day.from} - ${day.to}',
            style: TextStyles.boldStyle(
              13,
              color: day.isClosed
                  ? AppColors.redColor2
                  : AppColors.primaryColor,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
