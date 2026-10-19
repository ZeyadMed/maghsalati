import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/confirm_action_dialog.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/language_picker_sheet.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_menu_tile.dart';
import 'package:maghsalati/features/profile/presentation/view_model/delete_account_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

/// إعدادات الحساب والأمان: لغة الأبلكيشن، والأذونات، وحذف الحساب
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DeleteAccountCubit>(),
      // الكيوبت بيمسح الجلسة قبل ما يبعت success، فبنروح اللوجين على طول
      child: BlocListener<DeleteAccountCubit, BaseState<void>>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.showSuccessMessage('delete_account_success'.tr());
            context.go(AppRouter.login);
          }
          if (state.isFailure) {
            context.showErrorMessage(state.errorMessage ?? '');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.secondaryColor,
          appBar: CustomAppBar(
            title: 'account_settings',
            backgroundColor: AppColors.secondaryColor,
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            children: [
              _buildSectionTitle('settings_preferences'),
              _buildLanguageTile(context),
              SizedBox(height: 24.h),
              _buildSectionTitle('settings_security'),
              ProfileMenuTile(
                icon: Icons.admin_panel_settings_outlined,
                iconColor: AppColors.greenColor,
                titleKey: 'app_permissions',
                // الموقع والإشعارات والكاميرا كلهم بيتغيروا من إعدادات الجهاز
                onTap: openAppSettings,
              ),
              SizedBox(height: 12.h),
              _buildDeleteAccountTile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String titleKey) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 10.h),
      child: Text(
        titleKey.tr(),
        style: TextStyles.darkRegular12.copyWith(
          color: AppColors.greyColor3,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final currentCode = context.locale.languageCode;
    return ProfileMenuTile(
      icon: Icons.translate_rounded,
      iconColor: AppColors.primaryColor,
      titleKey: 'language',
      value: LanguagePickerSheet.languages[currentCode],
      onTap: () => _changeLanguage(context, currentCode),
    );
  }

  /// البوتوم ناف مربوط بمفتاح اللغة فبيتبني من الأول بالترجمة الجديدة،
  /// وبنرجع للرئيسية بدل ما نفضل في شاشة متبنية باللغة القديمة
  Future<void> _changeLanguage(BuildContext context, String currentCode) async {
    final code = await LanguagePickerSheet.show(
      context,
      selectedCode: currentCode,
    );
    if (code == null || code == currentCode || !context.mounted) return;

    await context.setLocale(Locale(code));
    if (context.mounted) context.go(AppRouter.initialRoot);
  }

  /// حذف الحساب بلون أحمر عشان يبان إنه إجراء خطير
  Widget _buildDeleteAccountTile() {
    return BlocBuilder<DeleteAccountCubit, BaseState<void>>(
      builder: (context, state) {
        return ProfileMenuTile(
          icon: Icons.delete_outline_rounded,
          iconColor: AppColors.redColor2,
          titleKey: 'delete_account',
          titleColor: AppColors.redColor2,
          // بنقفل السطر وقت الطلب عشان مايتبعتش مرتين
          onTap: state.isLoading ? null : () => _confirmDeleteAccount(context),
          trailing: state.isLoading
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.redColor2,
                  ),
                )
              : null,
        );
      },
    );
  }

  /// الحذف مابيترجعش فلازم تأكيد صريح قبل ما نبعت الريكوست
  Future<void> _confirmDeleteAccount(BuildContext blocContext) async {
    final shouldDelete = await showConfirmActionDialog(
      blocContext,
      titleKey: 'delete_account',
      messageKey: 'delete_account_confirm',
      confirmKey: 'delete_account_btn',
    );

    if (shouldDelete && blocContext.mounted) {
      blocContext.read<DeleteAccountCubit>().deleteAccount();
    }
  }
}
