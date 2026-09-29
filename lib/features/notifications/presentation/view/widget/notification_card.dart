import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/notifications/data/model/notification_model.dart';

/// كارت الإشعار: أيقونة حسب النوع والعنوان والنص والوقت
/// الإشعار اللي لسه ماتقراش خلفيته زرقا خفيفة وجنبه نقطة
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread ? AppColors.fillColor : AppColors.whiteColor,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isUnread
                  ? AppColors.primaryColor.withValues(alpha: 0.25)
                  : AppColors.borderColor,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              Gap(12.w),
              Expanded(child: _buildContent(context)),
              if (isUnread) ...[Gap(8.w), _buildUnreadDot()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconFor(notification.type),
        size: 20.r,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          notification.title,
          style: TextStyles.darkBold14.copyWith(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
          ),
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap(4.h),
        Text(
          notification.body,
          style: TextStyles.darkRegular12.copyWith(color: AppColors.greyColor),
          textAlign: TextAlign.start,
        ),
        Gap(8.h),
        Text(
          _formatDate(context, notification.createdAt),
          style: TextStyles.darkRegular12.copyWith(
            color: AppColors.greyColor4,
            fontSize: 11.sp,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      margin: EdgeInsets.only(top: 6.h),
      width: 8.r,
      height: 8.r,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
    );
  }

  /// إشعارات النهارده بيبان وقتها بس، والقديمة بيبان تاريخها كمان
  String _formatDate(BuildContext context, DateTime date) {
    final locale = context.locale.toString();
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      return '${'today'.tr()} ${DateFormat('hh:mm a', locale).format(date)}';
    }
    return DateFormat('d MMMM yyyy - hh:mm a', locale).format(date);
  }

  /// الأنواع اللي مش معروفة بتاخد أيقونة الجرس العادية
  IconData _iconFor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('order')) return Icons.local_laundry_service_outlined;
    if (lower.contains('delivery') || lower.contains('trip')) {
      return Icons.delivery_dining_outlined;
    }
    return Icons.notifications_none_rounded;
  }
}
