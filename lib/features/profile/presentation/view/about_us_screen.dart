import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/info_section_card.dart';

/// شاشة عن التطبيق: اللوجو ونبذة ومميزات التطبيق ورقم الإصدار
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  /// رقم الإصدار، لحد ما يتجاب من package_info
  static const String _version = '1.0.0';

  /// مميزات التطبيق اللي بتتعرض في النص
  static const List<_Feature> _features = [
    _Feature(
      titleKey: 'about_feature_fast_title',
      bodyKey: 'about_feature_fast_body',
      icon: Icons.bolt_outlined,
      color: AppColors.orangeColor,
    ),
    _Feature(
      titleKey: 'about_feature_quality_title',
      bodyKey: 'about_feature_quality_body',
      icon: Icons.workspace_premium_outlined,
      color: AppColors.primaryColor,
    ),
    _Feature(
      titleKey: 'about_feature_tracking_title',
      bodyKey: 'about_feature_tracking_body',
      icon: Icons.local_shipping_outlined,
      color: AppColors.greenColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'about_app',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrandCard(),
            SizedBox(height: 16.h),
            InfoSectionCard(
              titleKey: 'about_who_title',
              bodyKey: 'about_who_body',
              icon: Icons.info_outline_rounded,
            ),
            SizedBox(height: 14.h),
            for (int i = 0; i < _features.length; i++) ...[
              if (i > 0) SizedBox(height: 14.h),
              InfoSectionCard(
                titleKey: _features[i].titleKey,
                bodyKey: _features[i].bodyKey,
                icon: _features[i].icon,
                iconColor: _features[i].color,
              ),
            ],
            SizedBox(height: 22.h),
            _buildVersionRow(),
          ],
        ),
      ),
    );
  }

  /// كارت اللوجو فوق باللون الأساسي زي هيدر الرئيسية
  Widget _buildBrandCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlexibleImage(
            height: 56.h,
            width: 150.w,
            source: Assets.assetsImagesLogoLight,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 14.h),
          Text(
            'about_tagline'.tr(),
            textAlign: TextAlign.center,
            style: TextStyles.whiteText(14, weight: FontWeight.w300).copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.9),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  /// رقم الإصدار في آخر الشاشة
  Widget _buildVersionRow() {
    return Column(
      children: [
        Text(
          '${'app_version'.tr()} $_version',
          textAlign: TextAlign.center,
          style: TextStyles.darkRegular12.copyWith(
            color: AppColors.greyColor3,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'all_rights_reserved'.tr(),
          textAlign: TextAlign.center,
          style: TextStyles.darkRegular12.copyWith(
            color: AppColors.greyColor5,
          ),
        ),
      ],
    );
  }
}

/// ميزة واحدة من مميزات التطبيق
class _Feature {
  final String titleKey;
  final String bodyKey;
  final IconData icon;
  final Color color;

  const _Feature({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    required this.color,
  });
}
