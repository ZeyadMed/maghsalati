import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/auth/logout/presentation/logic/logout_bloc.dart';
import 'package:maghsalati/features/auth/logout/presentation/logic/logout_event.dart';
import 'package:maghsalati/features/profile/data/model/page_content_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/confirm_action_dialog.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_list_section.dart';

/// شاشة "المزيد" اللي بتتفتح من آخر قايمة حسابي، زي صفحة 更多 في التصميم الصيني:
/// الصفحات الثابتة، وتحتها تسجيل الخروج في سطر لوحده
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LogoutBloc>(),
      child: BlocListener<LogoutBloc, BaseState<void>>(
        listener: (context, state) {
          if (state.isSuccess) context.go(AppRouter.login);
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'more',
            backgroundColor: AppColors.scaffoldBackgroundColor,
          ),
          body: ListView(
            padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
            children: [
              ProfileListSection(
                children: [
                  // نفس المحتوى اللي بيظهر في ديالوج الشروط وقت تسجيل الدخول
                  ProfileListRow(
                    icon: Icons.lock_rounded,
                    iconColor: AppColors.greenColor,
                    titleKey: ContentPage.privacyPolicy.titleKey,
                    onTap: () => context.push(
                      AppRouter.contentPage,
                      extra: ContentPage.privacyPolicy,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              const _LogoutRow(),
            ],
          ),
        ),
      ),
    );
  }
}

/// تسجيل الخروج سطر أبيض والكلام أحمر في النص، عشان يبان إنه إجراء مختلف
class _LogoutRow extends StatelessWidget {
  const _LogoutRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogoutBloc, BaseState<void>>(
      builder: (context, state) {
        return Material(
          color: AppColors.whiteColor,
          child: InkWell(
            // بنقفل السطر وقت الطلب عشان مايتبعتش مرتين
            onTap: state.isLoading ? null : () => _confirmLogout(context),
            child: SizedBox(
              height: 52.h,
              child: Center(
                child: state.isLoading
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.redColor2,
                        ),
                      )
                    : Text(
                        'logout'.tr(),
                        style: TextStyles.boldStyle(
                          15,
                          color: AppColors.redColor2,
                          weight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// بنأكد قبل الخروج عشان مايخرجش بالغلط
  Future<void> _confirmLogout(BuildContext blocContext) async {
    final shouldLogout = await showConfirmActionDialog(
      blocContext,
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
}
