import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/splash/presentation/view_model/cubit/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    Timer(const Duration(seconds: 3), () {
      // Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..startSplashScreen(),
      child: BlocListener<SplashCubit, String>(
        listener: (context, state) {
          if (state == 'home') {
            GoRouter.of(context).pushReplacement(AppRouter.initialRoot);
          } else if (state == 'onboarding') {
            GoRouter.of(context).pushReplacement(AppRouter.onboarding);
          } else if (state == 'login') {
            GoRouter.of(context).pushReplacement(AppRouter.login);
          }
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor, // Color(0xFFf7f2ea),
                  AppColors.secondaryColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.assetsImagesFullLogo,
                    width: 300,
                    height: 300,
                    color: AppColors.blackColor.withOpacity(0.8),
                  ),
                  LocalizedLabel(
                    text: 'premium_arch',
                    style: TextStyles.darkBold14.copyWith(
                      fontSize: 14,
                      color: AppColors.blackColor.withOpacity(0.7),
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(
                    context.screenHeight * 0.1,
                  ), // Add spacing between logo and loading bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _animation.value,
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Gap(16.h), // Add spacing between loading bar and loading text
                  LocalizedLabel(
                    text: 'loading',
                    style: TextStyles.blackBold16.copyWith(
                      color: AppColors.blackColor.withOpacity(0.7),
                      fontSize: 14,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
