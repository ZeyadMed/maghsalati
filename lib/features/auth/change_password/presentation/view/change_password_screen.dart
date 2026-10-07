import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/common_widget/otp_text_field.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/helpers/validators.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/auth/change_password/presentation/logic/reset_password_bloc.dart';
import 'package:maghsalati/features/auth/change_password/presentation/logic/reset_password_event.dart';
import 'package:maghsalati/features/auth/forget_password/presentation/logic/forgot_password_bloc.dart';
import 'package:maghsalati/features/auth/forget_password/presentation/logic/forgot_password_event.dart';

class ChangePasswordScreen extends StatefulWidget {
  /// الرقم اللي اتبعتله الكود من شاشة نسيت كلمة المرور، وبيتبعت تاني
  /// مع الكود وكلمة المرور الجديدة في reset-password
  final String phoneNumber;

  const ChangePasswordScreen({super.key, this.phoneNumber = ''});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();

  static const int _otpLength = 6;

  static const int _countdownSeconds = 60;
  int _secondsRemaining = 0;
  bool _canResend = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // الكود لسه متبعت من شاشة نسيت كلمة المرور، فإعادة الإرسال بتستنى الأول
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _secondsRemaining = _countdownSeconds;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// إعادة الإرسال هي نفس forgot-password، والباك بيبعت كود جديد
  void _onResend(BuildContext context) {
    if (context.read<ForgotPasswordBloc>().state.isLoading) return;

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordEvent(phoneNumber: widget.phoneNumber),
    );
  }

  void _onSubmit(BuildContext context) {
    final isFormValid = _formKey.currentState!.validate();

    // حقل الكود له Form لوحده جوه OtpTextField، فبنتحقق منه هنا
    final code = _codeController.text.trim();
    if (code.length < _otpLength) {
      context.showErrorMessage('otp_required'.tr());
      return;
    }
    if (!isFormValid) return;
    if (context.read<ResetPasswordBloc>().state.isLoading) return;

    context.read<ResetPasswordBloc>().add(
      ResetPasswordEvent(
        phoneNumber: widget.phoneNumber,
        code: code,
        newPassword: _newPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ResetPasswordBloc>()),
        BlocProvider(create: (context) => getIt<ForgotPasswordBloc>()),
      ],
      child: BlocListener<ForgotPasswordBloc, BaseState<String>>(
        listener: (context, state) {
          if (state.isSuccess) {
            if (state.data?.isNotEmpty ?? false) {
              context.showSuccessMessage(state.data!);
            }
            setState(_startCountdown);
          }
          if (state.isFailure) {
            context.showErrorMessage(state.errorMessage ?? '');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.secondaryColor,
          body: BlocConsumer<ResetPasswordBloc, BaseState<String>>(
            listener: (context, state) {
              if (state.isSuccess) {
                context.showSuccessMessage(
                  (state.data?.isNotEmpty ?? false)
                      ? state.data!
                      : 'password_reset_success'.tr(),
                );
                // الباك مابيرجعش توكنز هنا، فالمستخدم بيدخل بكلمة المرور الجديدة
                context.go(AppRouter.login);
              }
              if (state.isFailure) {
                context.showErrorMessage(state.errorMessage ?? '');
              }
            },
            builder: (context, state) => _buildBody(context, state),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BaseState<String> state) {
    // الحقول زادت مع الكود فبنسمح بالسكرول عشان الكيبورد مايغطيش الزرار
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                Assets.assetsImagesLogo,
                width: double.infinity,
                height: context.screenHeight * 0.2,
                color: AppColors.blackColor,
              ),
              Gap(40.h),
              // Header
              LocalizedLabel(
                text: "change_password_title",
                style: TextStyles.blackBold32,
              ),

              Gap(10.h),

              // Description
              LocalizedLabel(
                text: "change_password_desc",
                maxLines: 3,
                style: TextStyles.blackRegular16.copyWith(
                  color: AppColors.lightTextColor,
                ),
              ),

              Gap(40.h),

              // OTP Field — نفس طول كود تفعيل الرقم
              OtpTextField(pinController: _codeController, length: _otpLength),

              Gap(16.h),

              // Countdown / Resend row
              _buildResendRow(),

              Gap(24.h),

              // New Password Field
              Customtextfield(
                textEditingController: _newPasswordController,
                hintText: 'new_password'.tr(),
                keyboardType: TextInputType.visiblePassword,
                prefix: const Icon(Icons.lock_outlined),
                validator: Validators.passwordValidator,
                obscureText: _obscureNewPassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),

              Gap(10.h),

              // Confirm New Password Field
              Customtextfield(
                textEditingController: _confirmPasswordController,
                hintText: 'confirm_new_password'.tr(),
                keyboardType: TextInputType.visiblePassword,
                prefix: const Icon(Icons.lock_outlined),
                validator: (value) => Validators.repeatPasswordValidator(
                  value: value,
                  Password: _newPasswordController.text,
                ),
                obscureText: _obscureConfirmPassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),

              Gap(30.h),

              // Change Password Button
              state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : CustomButton(
                      onPressed: () => _onSubmit(context),
                      title: "change_password_btn".tr(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    final actionStyle = TextStyles.blackBold14.copyWith(
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LocalizedLabel(
          text: "didnt_receive_otp",
          style: TextStyles.blackRegular16,
        ),
        Gap(6.w),
        BlocBuilder<ForgotPasswordBloc, BaseState<String>>(
          builder: (context, state) {
            if (state.isLoading) {
              return SizedBox.square(
                dimension: 16.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              );
            }
            if (!_canResend) {
              return Text(_formattedTime, style: actionStyle);
            }
            return GestureDetector(
              onTap: () => _onResend(context),
              child: LocalizedLabel(text: "resend_otp", style: actionStyle),
            );
          },
        ),
      ],
    );
  }
}
