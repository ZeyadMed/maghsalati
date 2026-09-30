import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/privacy_policy_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/retry_error_view.dart';
import 'package:maghsalati/features/profile/presentation/view_model/privacy_policy_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة سياسة الخصوصية: المحتوى HTML جاي من api/auth/privacy-policy
/// وبيتعرض في كارت واحد وتحته تاريخ آخر تحديث
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final PrivacyPolicyCubit _cubit = getIt<PrivacyPolicyCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getPrivacyPolicy();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'privacy_policy',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: BlocBuilder<PrivacyPolicyCubit, BaseState<PrivacyPolicyModel>>(
        bloc: _cubit,
        builder: (context, state) {
          final policy = state.data;
          if (state.isFailure) {
            return RetryErrorView(
              message: state.errorMessage,
              onRetry: _cubit.getPrivacyPolicy,
            );
          }
          if (policy == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          return _buildContent(policy);
        },
      ),
    );
  }

  Widget _buildContent(PrivacyPolicyModel policy) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: HtmlWidget(
              policy.content,
              textStyle: TextStyles.darkRegular14.copyWith(
                color: AppColors.greyColor2,
                height: 1.7,
              ),
              onTapUrl: _openLink,
            ),
          ),
          if (policy.updatedAt != null) ...[
            SizedBox(height: 12.h),
            Text(
              '${'last_updated'.tr()} ${DateFormat('d MMMM yyyy', context.locale.toString()).format(policy.updatedAt!)}',
              style: TextStyles.darkRegular12.copyWith(
                color: AppColors.greyColor4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// اللينكات اللي جوه السياسة بتفتح في المتصفح
  Future<bool> _openLink(String url) {
    return launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
  }
}
