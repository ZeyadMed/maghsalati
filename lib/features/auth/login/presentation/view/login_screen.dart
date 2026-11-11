import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/auth/login/presentation/logic/login_bloc.dart';
import 'package:maghsalati/features/auth/login/presentation/logic/login_event.dart';
import 'package:maghsalati/features/auth/login/presentation/view/widget/terms_dialog.dart';
import 'package:maghsalati/features/auth/otp/models/otp_args.dart';

import '../../../../../core/style/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  /// الرقم كامل بكود الدولة (+218911234567)، بيتحدث مع كل تغيير في الحقل
  /// بنستخدمه في تسجيل الدخول بدل نص الكنترولر اللي بيبقى الرقم المحلي بس
  String completePhone = '';

  /// زرار الدخول متعطل لحد ما يعلم على الشروط
  bool acceptedTerms = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginBloc>().add(LoginEvent(phoneNumber: completePhone));
  }

  /// الديالوج بيفتح من نص الشروط بس، وموافق جواه بيعلم على الـ checkbox
  Future<void> _openTerms() async {
    final agreed = await TermsDialog.show(context);
    if (agreed && mounted) setState(() => acceptedTerms = true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: Scaffold(
        body: BlocConsumer<LoginBloc, BaseState<String>>(
          listener: (context, state) {
            if (state.isSuccess) {
              // الكود اتبعت على الرقم، والتوكنز بتتحفظ بعد التحقق في شاشة الـ OTP
              if (state.data?.isNotEmpty ?? false) {
                context.showSuccessMessage(state.data!);
              }
              context.push(
                AppRouter.verifyOtp,
                extra: OtpArgs(
                  phoneNumber: completePhone,
                  purpose: OtpPurpose.login,
                ),
              );
            }
            if (state.isFailure) {
              context.showErrorMessage(state.errorMessage ?? '');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlexibleImage(
                      source: Assets.assetsImagesLogoLight,
                      width: double.infinity,
                      // height: 200.h,
                    ),
                    LocalizedLabel(
                      text: "welcome_back",
                      style: TextStyles.blackBold32,
                    ),
                    Gap(10.h),
                    LocalizedLabel(
                      text: "sign_in_to_zawaya",
                      style: TextStyles.blackRegular16,
                    ),
                    Gap(40.h),
                    // Phone Field
                    CustomPhoneField(
                      controller: phoneController,
                      onChanged: (phone) =>
                          completePhone = phone.completeNumber,
                      validator: (phone) => (phone == null || phone.isEmpty)
                          ? 'phoneNumberEmpty'.tr()
                          : null,
                    ),
                    Gap(15.h),

                    // Terms & Conditions
                    Row(
                      children: [
                        SizedBox(
                          width: 24.r,
                          height: 24.r,
                          child: Checkbox(
                            value: acceptedTerms,
                            onChanged: (value) =>
                                setState(() => acceptedTerms = value ?? false),
                            activeColor: AppColors.primaryColor,
                            checkColor: AppColors.whiteColor,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        Gap(8.w),
                        Expanded(
                          // Gap مابيشتغلش جوه Wrap فالمسافة من spacing
                          child: Wrap(
                            spacing: 4.w,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              LocalizedLabel(
                                text: "i_agree_to",
                                style: TextStyles.blackRegular14,
                              ),
                              GestureDetector(
                                onTap: _openTerms,
                                child: LocalizedLabel(
                                  text: "terms_and_conditions",
                                  style: TextStyles.blackBold14.copyWith(
                                    color: AppColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Gap(30.h),

                    // Sign In Button
                    state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                        : CustomButton(
                            onPressed: acceptedTerms
                                ? () => _onSubmit(context)
                                : null,
                            title: "sign_in".tr(),
                          ),
                    Gap(20.h),
                    // DividerWidget(text: "or".tr()),
                    // Gap(20.h),
                    // // Google & Apple Buttons
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CustomButton(
                    //         onPressed: () {
                    //           // TODO: Google Sign In
                    //         },
                    //         title: "Google",
                    //         fontSize: 14.sp,
                    //         isIcon: true,
                    //         icon: Image.asset(
                    //           Assets.assetsIconsGoogle,
                    //           width: 20.w,
                    //           height: 20.h,
                    //         ),
                    //         backgroundColor: Colors.white,
                    //         textColor: Colors.black,
                    //         borderColor: Colors.grey.shade300,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //     Gap(12.w),
                    //     Expanded(
                    //       child: CustomButton(
                    //         onPressed: () {
                    //           // TODO: Apple Sign In
                    //         },
                    //         title: "Apple",
                    //         fontSize: 14.sp,
                    //         isIcon: true,
                    //         icon: SvgPicture.asset(
                    //           Assets.assetsIconsApple,
                    //           width: 20.w,
                    //           height: 20.h,
                    //         ),
                    //         backgroundColor: Colors.white,
                    //         textColor: Colors.black,
                    //         borderColor: Colors.grey.shade300,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // Gap(30.h),

                    // Don't have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LocalizedLabel(
                          text: "dont_have_account",
                          style: TextStyles.blackRegular16,
                        ),
                        Gap(6.w),
                        GestureDetector(
                          onTap: () {
                            context.go(AppRouter.signUp);
                          },
                          child: LocalizedLabel(
                            text: "create_one",
                            style: TextStyles.blackBold16.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
