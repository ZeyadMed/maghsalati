import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// البانر اللي فوق الشيبس زي الديزاين: شريط أزرق مدوّر فيه هدوم على الطرف،
/// وعنوان كبير في النص، ودايرة صفرا "اضغط للعرض" على الطرف التاني
/// والدوسة على أي حتة فيه بتنفذ [onTap]
class ServicesPromoBanner extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const ServicesPromoBanner({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(40.r);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            height: 64.h,
            padding: EdgeInsetsDirectional.fromSTEB(8.w, 6.h, 8.w, 6.h),
            decoration: BoxDecoration(
              borderRadius: radius,
              // فاتح ناحية الهدوم وبيغمق ناحية الزرار، وبيتقلب مع العربي
              gradient: const LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [AppColors.mixedLightBlueColor, AppColors.primaryColor],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildClothes(),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyles.whiteText(18, weight: FontWeight.w800)
                          .copyWith(
                            shadows: [
                              Shadow(
                                color: AppColors.blackColor.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _buildViewButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// مكان صورة الهدوم اللي في الديزاين: جاكيت وتيشيرت راكبين على بعض
  Widget _buildClothes() {
    return SizedBox(
      width: 64.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            child: Text('🧥', style: TextStyle(fontSize: 30.sp)),
          ),
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Text('👕', style: TextStyle(fontSize: 26.sp)),
          ),
        ],
      ),
    );
  }

  /// دايرة على قد طول البانر عشان ماتطلعش بره مهما كان مقاس الشاشة
  Widget _buildViewButton() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: AppColors.lightOrangeColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.whiteColor, width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'tap_to_view'.tr(),
            textAlign: TextAlign.center,
            style: TextStyles.boldStyle(
              11,
              color: AppColors.fontDarkColor,
            ).copyWith(height: 1.2),
          ),
        ),
      ),
    );
  }
}
