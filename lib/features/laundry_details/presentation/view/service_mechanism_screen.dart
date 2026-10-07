import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/info_section_card.dart';

/// شاشة آلية تقديم الخدمة اللي بتتفتح من زرارها في شاشة مقدم الخدمة
/// كارت للغسيل وكارت للتوصيل، والنص ثابت في الترجمة
class ServiceMechanismScreen extends StatelessWidget {
  const ServiceMechanismScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'service_mechanism',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const InfoSectionCard(
              titleKey: 'service_mechanism_washing_title',
              bodyKey: 'service_mechanism_washing_body',
              icon: Icons.local_laundry_service_outlined,
            ),
            SizedBox(height: 14.h),
            const InfoSectionCard(
              titleKey: 'service_mechanism_delivery_title',
              bodyKey: 'service_mechanism_delivery_body',
              icon: Icons.local_shipping_outlined,
              iconColor: AppColors.greenColor,
            ),
          ],
        ),
      ),
    );
  }
}
