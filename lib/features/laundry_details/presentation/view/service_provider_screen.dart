import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/info_section_card.dart';

/// شاشة مقدم الخدمة اللي بتتفتح من اختصارات تفاصيل المغسلة
/// النص ثابت في الترجمة، وزرار آلية تقديم الخدمة بيفتح شاشتها
class ServiceProviderScreen extends StatelessWidget {
  const ServiceProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'service_provider',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrandCard(),
            SizedBox(height: 16.h),
            const InfoSectionCard(
              titleKey: 'service_provider_intro_title',
              bodyKey: 'service_provider_intro_body',
              icon: Icons.verified_outlined,
            ),
            SizedBox(height: 14.h),
            _buildMechanismButton(context),
          ],
        ),
      ),
    );
  }

  /// كارت اللوجو فوق باللون الأساسي زي شاشة عن التطبيق
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
            'service_provider_tagline'.tr(),
            textAlign: TextAlign.center,
            style: TextStyles.whiteBold15.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }

  /// نفس شكل زرار مواعيد العمل في تفاصيل المغسلة
  Widget _buildMechanismButton(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => context.push(AppRouter.serviceMechanism),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 20.r,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'service_mechanism'.tr(),
                  style: TextStyles.darkBold14,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: AppColors.greyColor2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
