import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/helpers/validators.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/core/widget/divider_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String _phoneNumber = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(50.h),
              LocalizedLabel(
                text: "create_account",
                style: TextStyles.blackBold32,
              ),
              Gap(10.h),
              LocalizedLabel(
                text: "sign_up_to_zawaya",
                style: TextStyles.blackRegular16,
              ),
              Gap(40.h),

              // Name Field
              Customtextfield(
                textEditingController: nameController,
                hintText: 'full_name'.tr(),
                keyboardType: TextInputType.name,
                prefix: const Icon(Icons.person_outlined),
                validator: Validators.displayNameValidator,
              ),
              Gap(10.h),

              // Email Field
              Customtextfield(
                textEditingController: emailController,
                hintText: 'email'.tr(),
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.email_outlined),
                validator: Validators.emailValidator,
              ),
              Gap(20.h),

              // Phone Field
              CustomPhoneField(
                onChanged: (phone) {
                  print(phone.completeNumber);
                },
              ),
              Gap(10.h),

              // Password Field
              Customtextfield(
                hintText: 'password'.tr(),
                keyboardType: TextInputType.visiblePassword,
                prefix: const Icon(Icons.lock_outlined),
                validator: Validators.passwordValidator,
                textEditingController: passwordController,
                obscureText: obscurePassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              Gap(10.h),

              // Confirm Password Field
              Customtextfield(
                hintText: 'confirm_password'.tr(),
                keyboardType: TextInputType.visiblePassword,
                prefix: const Icon(Icons.lock_outlined),
                validator: (value) => Validators.repeatPasswordValidator(
                  value: value,
                  Password: passwordController.text,
                ),
                textEditingController: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(
                      () => obscureConfirmPassword = !obscureConfirmPassword,
                    );
                  },
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),

              Gap(30.h),

              // Sign Up Button
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.go(AppRouter.verifyOtp);
                  }
                },
                title: "sign_up".tr(),
              ),
              Gap(20.h),
              DividerWidget(text: "or".tr()),
              Gap(20.h),

              // Google & Apple Buttons
              // Row(
              //   children: [
              //     Expanded(
              //       child: CustomButton(
              //         onPressed: () {
              //           // TODO: Google Sign Up
              //         },
              //         title: "Google",
              //         fontSize: 14.sp,
              //         isIcon: true,
              //         icon: SvgPicture.asset(Assets.assetsIconsGoogle,
              //             width: 20.w, height: 20.h),
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
              //           // TODO: Apple Sign Up
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

              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LocalizedLabel(
                    text: "already_have_account",
                    style: TextStyles.blackRegular16,
                  ),
                  Gap(6.w),
                  GestureDetector(
                    onTap: () {
                      context.go(AppRouter.login);
                    },
                    child: LocalizedLabel(
                      text: "sign_in_now",
                      style: TextStyles.blackBold16.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(30.h),
            ],
          ),
        ),
      ),
    );
  }
}
