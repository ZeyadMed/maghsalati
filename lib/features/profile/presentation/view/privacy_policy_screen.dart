import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/info_section_card.dart';

/// شاشة سياسة الخصوصية: مقدمة فوق وتحتها كروت كل واحد فيه بند
/// البنود جاية من ملفات الترجمة فبتتغير مع اللغة لوحدها
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  /// بنود السياسة بالترتيب اللي بتتعرض بيه
  static const List<_PolicySection> _sections = [
    _PolicySection(
      titleKey: 'privacy_data_title',
      bodyKey: 'privacy_data_body',
      icon: Icons.folder_outlined,
      color: AppColors.primaryColor,
    ),
    _PolicySection(
      titleKey: 'privacy_usage_title',
      bodyKey: 'privacy_usage_body',
      icon: Icons.settings_outlined,
      color: AppColors.lightBlueColor,
    ),
    _PolicySection(
      titleKey: 'privacy_sharing_title',
      bodyKey: 'privacy_sharing_body',
      icon: Icons.share_outlined,
      color: AppColors.orangeColor,
    ),
    _PolicySection(
      titleKey: 'privacy_security_title',
      bodyKey: 'privacy_security_body',
      icon: Icons.shield_outlined,
      color: AppColors.greenColor,
    ),
    _PolicySection(
      titleKey: 'privacy_rights_title',
      bodyKey: 'privacy_rights_body',
      icon: Icons.verified_user_outlined,
      color: AppColors.primaryColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'privacy_policy',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIntro(),
            SizedBox(height: 16.h),
            for (int i = 0; i < _sections.length; i++) ...[
              if (i > 0) SizedBox(height: 14.h),
              InfoSectionCard(
                titleKey: _sections[i].titleKey,
                bodyKey: _sections[i].bodyKey,
                icon: _sections[i].icon,
                iconColor: _sections[i].color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// كارت المقدمة، لونه أزرق باهت عشان يفرق عن باقي البنود
  Widget _buildIntro() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'privacy_intro_title'.tr(),
            style: TextStyles.darkBold16.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'privacy_intro_body'.tr(),
            style: TextStyles.darkRegular14.copyWith(
              color: AppColors.greyColor2,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

/// بند واحد من بنود السياسة
class _PolicySection {
  final String titleKey;
  final String bodyKey;
  final IconData icon;
  final Color color;

  const _PolicySection({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    required this.color,
  });
}
