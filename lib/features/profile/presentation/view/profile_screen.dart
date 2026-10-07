import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/auth/logout/presentation/logic/logout_bloc.dart';
import 'package:maghsalati/features/auth/logout/presentation/logic/logout_event.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_header.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_menu_tile.dart';
import 'package:maghsalati/features/profile/presentation/view_model/delete_account_cubit.dart';
import 'package:maghsalati/features/profile/presentation/view_model/profile_cubit.dart';

/// شاشة حسابي: هيدر أزرق فيه بيانات المستخدم وتحته قايمة الصفحات
/// بيانات المستخدم جاية من api/customer/profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileCubit _profileCubit = getIt<ProfileCubit>();

  @override
  void initState() {
    super.initState();
    _profileCubit.getProfile();
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  /// بيفتح شاشة تعديل الملف وبيستنى البيانات الجديدة ترجع منها
  /// لو المستخدم حفظ، الهيدر بيتحدث على طول من غير ما نعيد تحميل الشاشة
  /// ولو البيانات لسه ماوصلتش الدوسة مابتعملش حاجة
  Future<void> _openUpdateProfile() async {
    final user = _profileCubit.state.data;
    if (user == null) return;

    final updated = await context.push<UserModel>(
      AppRouter.updateProfileScreen,
      extra: user,
    );

    if (updated != null && mounted) _profileCubit.setUser(updated);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<LogoutBloc>()),
        BlocProvider(create: (context) => getIt<DeleteAccountCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LogoutBloc, BaseState<void>>(
            listener: (context, state) {
              if (state.isSuccess) context.go(AppRouter.login);
            },
          ),
          // الكيوبت بيمسح الجلسة قبل ما يبعت success، فبنروح اللوجين على طول
          BlocListener<DeleteAccountCubit, BaseState<void>>(
            listener: (context, state) {
              if (state.isSuccess) {
                context.showSuccessMessage('delete_account_success'.tr());
                context.go(AppRouter.login);
              }
              if (state.isFailure) {
                context.showErrorMessage(state.errorMessage ?? '');
              }
            },
          ),
        ],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Column(
        children: [
          BlocBuilder<ProfileCubit, BaseState<UserModel>>(
            bloc: _profileCubit,
            builder: (context, state) => ProfileHeader(
              user: state.data,
              hasError: state.isFailure,
              onRetry: _profileCubit.getProfile,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._buildMenuTiles(),
                  SizedBox(height: 24.h),
                  _buildLogoutButton(),
                  SizedBox(height: 8.h),
                  _buildDeleteAccountButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// سطور القايمة، بينهم مسافة ثابتة من غير ما تتحط تحت آخر واحد
  List<Widget> _buildMenuTiles() {
    final tiles = <Widget>[
      ProfileMenuTile(
        icon: Icons.edit_outlined,
        iconColor: AppColors.primaryColor,
        titleKey: 'edit_profile',
        onTap: _openUpdateProfile,
      ),
      ProfileMenuTile(
        icon: Icons.notifications_none_rounded,
        iconColor: AppColors.orangeColor,
        titleKey: 'notifications',
        onTap: () => context.push(AppRouter.notificationScreen),
      ),
      ProfileMenuTile(
        icon: Icons.lock_outline_rounded,
        iconColor: AppColors.greenColor,
        titleKey: 'privacy_policy',
        onTap: () => context.push(AppRouter.privacyPolicy),
      ),
      ProfileMenuTile(
        icon: Icons.chat_bubble_outline_rounded,
        iconColor: AppColors.lightBlueColor,
        titleKey: 'contact_us',
        onTap: () => context.push(AppRouter.contactUsScreen),
      ),
      // ProfileMenuTile(
      //   icon: Icons.info_outline_rounded,
      //   iconColor: AppColors.orangeColor,
      //   titleKey: 'about_app',
      //   onTap: () => context.push(AppRouter.aboutUs),
      // ),
    ];

    return [
      for (int i = 0; i < tiles.length; i++) ...[
        if (i > 0) SizedBox(height: 12.h),
        tiles[i],
      ],
    ];
  }

  /// زرار تسجيل الخروج، لونه أحمر باهت عشان يبان إنه إجراء مختلف عن باقي القايمة
  Widget _buildLogoutButton() {
    return BlocBuilder<LogoutBloc, BaseState<void>>(
      builder: (context, state) {
        return Material(
          color: AppColors.redColor2.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            // بنقفل الزرار وقت الطلب عشان مايتبعتش مرتين
            onTap: state.isLoading ? null : () => _confirmLogout(context),
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: state.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.redColor2,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 19.r,
                          color: AppColors.redColor2,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'logout'.tr(),
                          style: TextStyles.darkBold16.copyWith(
                            color: AppColors.redColor2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  /// حذف الحساب أقل بروزاً من الخروج عشان مايتداسش عليه بالغلط،
  /// ومن غير خلفية بس بنفس اللون الأحمر عشان يبان إنه إجراء خطير
  Widget _buildDeleteAccountButton() {
    return BlocBuilder<DeleteAccountCubit, BaseState<void>>(
      builder: (context, state) {
        return TextButton(
          onPressed: state.isLoading
              ? null
              : () => _confirmDeleteAccount(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          child: state.isLoading
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.redColor2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18.r,
                      color: AppColors.redColor2,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'delete_account'.tr(),
                      style: TextStyles.darkRegular14.copyWith(
                        color: AppColors.redColor2,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// بنأكد قبل الخروج عشان مايخرجش بالغلط
  Future<void> _confirmLogout(BuildContext blocContext) async {
    final shouldLogout = await _showConfirmDialog(
      titleKey: 'logout',
      messageKey: 'logout_confirm',
      confirmKey: 'logout',
    );

    // الـ bloc بيبعت الـ refreshToken للباك ويمسح الكاش،
    // والتوجيه للوجين بيحصل في الـ BlocListener
    if (shouldLogout && blocContext.mounted) {
      blocContext.read<LogoutBloc>().add(const LogoutEvent());
    }
  }

  /// الحذف مابيترجعش فلازم تأكيد صريح قبل ما نبعت الريكوست
  Future<void> _confirmDeleteAccount(BuildContext blocContext) async {
    final shouldDelete = await _showConfirmDialog(
      titleKey: 'delete_account',
      messageKey: 'delete_account_confirm',
      confirmKey: 'delete_account_btn',
    );

    if (shouldDelete && blocContext.mounted) {
      blocContext.read<DeleteAccountCubit>().deleteAccount();
    }
  }

  /// ديالوج تأكيد بزرارين، بيرجع true لو المستخدم أكد بس
  /// (الإلغاء أو القفل من بره الديالوج بيرجعوا false)
  Future<bool> _showConfirmDialog({
    required String titleKey,
    required String messageKey,
    required String confirmKey,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          titleKey.tr(),
          style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          messageKey.tr(),
          style: TextStyles.darkRegular14.copyWith(
            color: AppColors.greyColor2,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(
              'cancel'.tr(),
              style: TextStyles.darkBold14.copyWith(
                color: AppColors.greyColor2,
              ),
            ),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              confirmKey.tr(),
              style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
