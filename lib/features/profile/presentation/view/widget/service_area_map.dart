import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الجزء اللي فوق في شاشة نطاق الخدمة زي التطبيق الصيني:
/// جملة بالأزرق في النص، خط رفيع تحتها، وخريطة ليبيا بشعبياتها ملونة
/// وطرابلس بالأحمر، وفي الركن الشمال تحت المندوب ومعاه "المناطق المتاحة"
/// بياخد المساحة اللي بتتديله كلها والخريطة بتصغر عشان تدخل فيها
class ServiceAreaMap extends StatelessWidget {
  const ServiceAreaMap({super.key});

  /// نسبة عرض لطول الـ viewBox بتاع libya_map.svg (1012 × 974)
  static const double _mapAspectRatio = 1012 / 974;

  static const Color _headlineColor = Color(0xff5B8EE8);
  static const Color _dividerColor = Color(0xffB5DCF2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
          child: Text(
            'service_area_headline'.tr(),
            style: TextStyles.darkBold18.copyWith(color: _headlineColor),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(28.w, 10.h, 28.w, 16.h),
          child: const Divider(height: 1, thickness: 1, color: _dividerColor),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Center(
              child: AspectRatio(
                aspectRatio: _mapAspectRatio,
                child: LayoutBuilder(builder: _buildMap),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(BuildContext context, BoxConstraints box) {
    return Stack(
      children: [
        Positioned.fill(child: SvgPicture.asset(Assets.assetsImagesLibyaMap)),
        // الركن الشمال تحت فاضي في الخريطة (جنوب غرب ليبيا) فبيتحط فيه
        // بـ left مش start عشان مكانه ثابت على الخريطة في العربي والإنجليزي
        Positioned(
          left: box.maxWidth * 0.02,
          bottom: box.maxHeight * 0.02,
          child: Row(
            textDirection: ui.TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SvgPicture.asset(
                Assets.assetsImagesServiceAreaMascot,
                height: box.maxHeight * 0.22,
              ),
              SizedBox(width: 4.w),
              Text(
                'service_area_available'.tr(),
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor,
                  fontSize: 11.sp,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
