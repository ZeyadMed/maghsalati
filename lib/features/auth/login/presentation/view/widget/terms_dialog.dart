import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/page_content_model.dart';
import 'package:maghsalati/features/profile/presentation/view_model/page_content_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// ديالوج الشروط والأحكام في شاشة الدخول، المحتوى HTML جاي من
/// api/auth/privacy-policy وزرار الموافقة مابيشتغلش غير لما المحتوى يحمّل
class TermsDialog extends StatefulWidget {
  const TermsDialog({super.key});

  /// بيرجع true لو المستخدم داس موافق، وأي قفل تاني بيرجع false
  static Future<bool> show(BuildContext context) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (_) => const TermsDialog(),
    );
    return agreed ?? false;
  }

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  final PageContentCubit _cubit = getIt<PageContentCubit>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _cubit.load(ContentPage.privacyPolicy);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageContentCubit, BaseState<PageContentModel>>(
      bloc: _cubit,
      builder: (context, state) {
        final policy = state.isSuccess ? state.data : null;
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
          title: Text(
            'terms_and_conditions'.tr(),
            style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: state.isFailure
                ? _buildFailure(state.errorMessage)
                : policy == null
                ? _buildLoading()
                : _buildContent(policy),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'cancel'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: AppColors.greyColor3,
                ),
              ),
            ),
            TextButton(
              onPressed: policy == null
                  ? null
                  : () => Navigator.of(context).pop(true),
              child: Text(
                'agree'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: policy == null
                      ? AppColors.greyColor5
                      : AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(PageContentModel policy) {
    return SingleChildScrollView(
      child: HtmlWidget(
        policy.content,
        textStyle: TextStyles.darkRegular14.copyWith(
          color: AppColors.greyColor2,
          height: 1.7,
        ),
        onTapUrl: _openLink,
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 120.h,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
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
          onPressed: _load,
          child: LocalizedLabel(
            text: 'try_again',
            style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  /// اللينكات اللي جوه الشروط بتفتح في المتصفح
  Future<bool> _openLink(String url) {
    return launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
  }
}
