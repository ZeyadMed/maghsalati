import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// شاشة نطاق الخدمة اللي بتتفتح من اختصارات تفاصيل المغسلة
/// النص ثابت في الترجمة لأن مفيش endpoint بيرجعه
class ServiceAreaScreen extends StatelessWidget {
  const ServiceAreaScreen({super.key});

  /// نمطين الخدمة اللي بيتعرضوا تحت جملة المقدمة
  static const List<(IconData, String)> _modes = [
    (Icons.home_work_outlined, 'service_area_mode_home_manager'),
    (Icons.local_shipping_outlined, 'service_area_mode_pickup_delivery'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'service_area',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              children: [
                Text(
                  'service_area_modes_intro'.tr(),
                  style: TextStyles.darkBold16,
                ),
                for (final (icon, textKey) in _modes) ...[
                  SizedBox(height: 12.h),
                  _buildModeRow(icon, textKey),
                ],
              ],
            ),
            SizedBox(height: 14.h),
            _buildCard(
              children: [
                _buildParagraph('service_area_coverage'),
                SizedBox(height: 12.h),
                _buildParagraph('service_area_commitment'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// نفس شكل كروت شاشة عن التطبيق عشان الشاشات الثابتة تبقى شبه بعض
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildModeRow(IconData icon, String textKey) {
    return Row(
      children: [
        Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18.r, color: AppColors.primaryColor),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(textKey.tr(), style: TextStyles.darkBold14),
        ),
      ],
    );
  }

  Widget _buildParagraph(String textKey) {
    return Text(
      textKey.tr(),
      style: TextStyles.darkRegular14.copyWith(
        color: AppColors.greyColor2,
        height: 1.7,
      ),
    );
  }
}
