import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart'; // لو هتستخدم assets

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<String> titles = [
    'discover_premium_designs_title'.tr(),
    'customize_with_experts_title'.tr(),
    'download_build_easily_title'.tr(),
  ];

  final List<String> descriptions = [
    'discover_premium_designs_description'.tr(),
    'customize_with_experts_description'.tr(),
    'download_build_easily_description'.tr(),
  ];

  // غير الصور دي بصورك الثلاثة
  final List<String> images = [
    Assets.assetsImagesOnboarding1, // صورة 1
    Assets.assetsImagesOnboarding3, // صورة 3
    Assets.assetsImagesOnboarding2, // صورة 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Align(
          //   alignment: Alignment.topRight,
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: TextButton(
          //       onPressed: () {
          //         context.go(AppRouter.login);
          //       },
          //       child: LocalizedLabel(
          //         text: "skip",
          //         style: TextStyle(color: Colors.grey, fontSize: 16),
          //       ),
          //     ),
          //   ),
          // ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() => currentPage = page);
              },
              itemCount: 3,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        child: FlexibleImage(
                          source: images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            LocalizedLabel(
                              text: titles[index].tr(),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyles.blackBold16.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            LocalizedLabel(
                              text: descriptions[index].tr(),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyles.blackRegular16.copyWith(
                                fontSize: 16,
                                color: AppColors.greyColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Indicators + Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicators
                Row(
                  children: List.generate(
                    3,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      width: currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? AppColors.primaryColor
                            : Color(0xFFd4c4b0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Continue / Next Button
                CustomButton(
                  onPressed: () {
                    if (currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      SharedPreferences.getInstance().then(
                        (prefs) => prefs.setBool('hasSeenOnboarding', true),
                      );
                      context.go(AppRouter.login);
                    }
                  },
                  backgroundColor: AppColors.highlightColor,
                  textColor: Colors.black87,
                  borderRadius: 24,
                  fontSize: 14.sp,
                  width: context.screenWidth * 0.3,
                  title:
                      currentPage == 2 ? "get_started".tr() : "continue".tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
