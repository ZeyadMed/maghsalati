import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/helpers/validators.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/auth/login/presentation/logic/login_bloc.dart';
import 'package:maghsalati/features/auth/login/presentation/logic/login_event.dart';
import 'package:maghsalati/features/auth/models/auth_model.dart';

import '../../../../../core/style/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// الرقم كامل بكود الدولة (+218911234567)، بيتحدث مع كل تغيير في الحقل
  /// بنستخدمه في تسجيل الدخول بدل نص الكنترولر اللي بيبقى الرقم المحلي بس
  String completePhone = '';
  bool obscureText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginBloc>().add(
      LoginEvent(
        phoneNumber: completePhone,
        password: passwordController.text,
        rememberMe: true,
        deviceInfo: '',
        deviceId: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        body: BlocConsumer<LoginBloc, BaseState<AuthModel>>(
          listener: (context, state) {
            if (state.isSuccess) {
              // التوكنز اتحفظت جوه authenticate فبنوديه الناف بار على طول
              context.showSuccessMessage(state.data?.message ?? '');
              context.go(AppRouter.initialRoot);
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
                onChanged: (phone) => completePhone = phone.completeNumber,
                validator: (phone) => (phone == null || phone.isEmpty)
                    ? 'phoneNumberEmpty'.tr()
                    : null,
              ),
              Gap(10.h),

              // Password Field
              Customtextfield(
                hintText: 'password'.tr(),
                keyboardType: TextInputType.visiblePassword,
                prefix: const Icon(Icons.lock_outlined),
                validator: Validators.passwordValidator,
                textEditingController: passwordController,
                obscureText: obscureText,
                suffix: IconButton(
                  onPressed: () {
                    setState(() => obscureText = !obscureText);
                  },
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),

              Gap(15.h),

              // Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.go(AppRouter.forgetPassword);
                    },
                    child: LocalizedLabel(
                      text: "forgot_password",
                      style: TextStyles.blackBold14.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
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
                      onPressed: () => _onSubmit(context),
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
