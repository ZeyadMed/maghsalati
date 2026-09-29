import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/common_widget/custom_error_message.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/notifications/data/model/notification_model.dart';
import 'package:maghsalati/features/notifications/presentation/view/widget/notification_card.dart';
import 'package:maghsalati/features/notifications/presentation/view_model/notifications_cubit.dart';

enum _NotificationsAction { readAll, deleteAll }

/// شاشة الإشعارات: الإشعارات بتيجي من api/laundry/notifications صفحة صفحة
/// الضغط على الإشعار بيعلمه كمقروء، والسحب بيمسحه، والقايمة اللي فوق
/// فيها تعليم الكل كمقروء ومسح الكل
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsCubit _cubit = getIt<NotificationsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getNotifications();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// بيعرض رسالة الخطأ لو العملية فشلت، والـ cubit بيكون رجع الليستة
  Future<void> _run(Future<String?> action) async {
    final error = await action;
    if (error != null && mounted) {
      CustomErrorOverlay.show(context: context, text: error);
    }
  }

  Future<void> _onActionSelected(_NotificationsAction action) async {
    switch (action) {
      case _NotificationsAction.readAll:
        await _run(_cubit.markAllAsRead());
      case _NotificationsAction.deleteAll:
        if (await _confirmDeleteAll()) await _run(_cubit.deleteAll());
    }
  }

  /// بنأكد قبل مسح كل الإشعارات عشان مايمسحهاش بالغلط
  Future<bool> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'delete_all_notifications'.tr(),
          style: TextStyles.darkBold16,
        ),
        content: Text(
          'delete_all_notifications_message'.tr(),
          style: TextStyles.greyColor2Regular14,
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text('cancel'.tr(), style: TextStyles.greyColor2Regular14),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              'delete_all'.tr(),
              style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// بتتنادى بعد الفريم عشان الـ emit مايحصلش وسط الـ build
  void _loadMoreAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _cubit.loadMore());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'notifications',
        backgroundColor: AppColors.secondaryColor,
        actions: [_buildActionsMenu()],
      ),
      body: BlocBuilder<NotificationsCubit, BaseState<NotificationModel>>(
        bloc: _cubit,
        builder: (context, state) => RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: _cubit.getNotifications,
          child: _buildBody(state),
        ),
      ),
    );
  }

  /// بتظهر بس لو فيه إشعارات، و"تعليم الكل كمقروء" بس لو فيه غير مقروء
  Widget _buildActionsMenu() {
    return BlocBuilder<NotificationsCubit, BaseState<NotificationModel>>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();

        return PopupMenuButton<_NotificationsAction>(
          icon: const Icon(Icons.more_vert, color: AppColors.darkTextColor),
          color: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          onSelected: _onActionSelected,
          itemBuilder: (_) => [
            if (_cubit.hasUnread)
              _buildMenuItem(
                _NotificationsAction.readAll,
                Icons.done_all_rounded,
                'mark_all_as_read',
                AppColors.primaryColor,
              ),
            _buildMenuItem(
              _NotificationsAction.deleteAll,
              Icons.delete_outline_rounded,
              'delete_all',
              AppColors.redColor2,
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<_NotificationsAction> _buildMenuItem(
    _NotificationsAction value,
    IconData icon,
    String titleKey,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: color),
          Gap(10.w),
          Text(titleKey.tr(), style: TextStyles.darkRegular14),
        ],
      ),
    );
  }

  Widget _buildBody(BaseState<NotificationModel> state) {
    // أول تحميل أو فشل ومفيش إشعارات قديمة نعرضها
    if (state.items.isEmpty) {
      if (state.isFailure) return _buildScrollableCenter(_buildError(state));
      if (state.isInitial || state.isLoading) {
        return _buildScrollableCenter(_buildLoading());
      }
      // اليوزر مسح كل اللي اتحمل وفيه صفحات لسه، فبنكمل تحميل
      if (!state.hasReachedMax) {
        if (!state.isLoadingMoreFauilare) _loadMoreAfterFrame();
        return _buildScrollableCenter(_buildLoading());
      }
      return _buildScrollableCenter(_buildEmptyState());
    }

    final notifications = state.items;
    final showLoader = !state.hasReachedMax;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: notifications.length + (showLoader ? 1 : 0),
      separatorBuilder: (_, _) => Gap(12.h),
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          // اللودر آخر الليستة، أول ما يترسم بنجيب الصفحة اللي بعدها
          if (!state.isLoadingMoreFauilare) _loadMoreAfterFrame();
          return _buildLoading();
        }

        final notification = notifications[index];
        return _buildDismissible(notification);
      },
    );
  }

  /// السحب في أي اتجاه بيمسح الإشعار
  Widget _buildDismissible(NotificationModel notification) {
    return Dismissible(
      key: ValueKey(notification.id),
      background: _buildDeleteBackground(AlignmentDirectional.centerStart),
      secondaryBackground: _buildDeleteBackground(
        AlignmentDirectional.centerEnd,
      ),
      onDismissed: (_) => _run(_cubit.deleteNotification(notification.id)),
      child: NotificationCard(
        notification: notification,
        onTap: () => _run(_cubit.markAsRead(notification.id)),
      ),
    );
  }

  Widget _buildDeleteBackground(AlignmentGeometry alignment) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.redColor2,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: AppColors.whiteColor,
        size: 24.r,
      ),
    );
  }

  /// الحالات اللي في النص لازم تبقى جوه scrollable عشان السحب للتحديث يشتغل
  Widget _buildScrollableCenter(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildError(BaseState<NotificationModel> state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 56.r, color: AppColors.greyColor5),
          Gap(12.h),
          Text(
            state.errorMessage ?? 'try_again'.tr(),
            style: TextStyles.darkBold16,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _cubit.getNotifications,
            child: Text(
              'try_again'.tr(),
              style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.notifications_off_outlined,
          size: 56.r,
          color: AppColors.greyColor4,
        ),
        Gap(12.h),
        Text(
          'no_notifications'.tr(),
          style: TextStyles.darkRegular14.copyWith(color: AppColors.greyColor3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
