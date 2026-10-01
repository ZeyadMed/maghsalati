import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/realtime/realtime_service.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// شريط صغير "جاري إعادة الاتصال…" بيظهر بس والـ hub بيحاول يرجع بعد ما وقع
/// (مش وقت أول اتصال، ولا لو اليوزر ضيف أو الاتصال مقفول خالص)
class RealtimeStatusBar extends StatelessWidget {
  final ValueListenable<RealtimeStatus> status;

  const RealtimeStatusBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RealtimeStatus>(
      valueListenable: status,
      builder: (context, value, _) {
        final visible = value == RealtimeStatus.reconnecting;
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: visible
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  color: AppColors.orangeColor.withValues(alpha: 0.12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 12.r,
                        height: 12.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.orangeColor,
                        ),
                      ),
                      Gap(8.w),
                      Text(
                        'realtime_reconnecting'.tr(),
                        style: TextStyles.darkRegular12.copyWith(
                          color: AppColors.orangeColor,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        );
      },
    );
  }
}
