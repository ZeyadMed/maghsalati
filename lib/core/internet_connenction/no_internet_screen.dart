import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:maghsalati/core/internet_connenction/internet_connenction_cubit.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';

/// بتظهر مكان الأبلكيشن كله لما النت يفصل، ولما يرجع بتختفي لوحدها؛
/// وزرار إعادة المحاولة بيفحص الاتصال تاني فوراً من غير مايستنى تغيير الشبكة
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(Assets.assetsIconsLottieJson, height: 200.h),
                Gap(20.h),
                Text(
                  "noInternet".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyles.darkBold20.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Text(
                    "checkInternet".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyles.darkRegular14.copyWith(
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
                Gap(30.h),
                CustomButton(
                  title: "retry",
                  borderRadius: 30.r,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  fontWeight: FontWeight.w500,
                  onPressed: () => context.read<InternetCubit>().retry(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
