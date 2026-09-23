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
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_drop_down.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/core/widget/divider_widget.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/auth/register/models/city_model.dart';
import 'package:maghsalati/features/auth/register/models/register_model.dart';
import 'package:maghsalati/features/auth/register/presentation/logic/city_cubit.dart';
import 'package:maghsalati/features/auth/register/presentation/logic/register_bloc.dart';
import 'package:maghsalati/features/auth/register/presentation/logic/register_event.dart';
import 'package:maghsalati/features/auth/register/presentation/view/widget/location_picker_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  /// الرقم كامل بكود الدولة (+218911234567)، بيتحدث مع كل تغيير في الحقل
  /// وده اللي بيتبعت للباك اند مش نص الكنترولر
  String completePhone = '';

  /// المدينة المختارة، بنبعت الـ id بتاعها في cityId
  CityModel? selectedCity;

  /// الإحداثيات اللي جات من تحديد الموقع، بتفضل 0 لو المستخدم ماحددش
  double latitude = 0;
  double longitude = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

     
    if (selectedCity == null) {
      context.showErrorMessage('select_city_first'.tr());
      return;
    }

    context.read<RegisterBloc>().add(
      RegisterEvent(
        name: nameController.text.trim(),
        phoneNumber: completePhone,
        password: passwordController.text,
        address: addressController.text.trim(),
        cityId: selectedCity!.id,
        latitude: latitude,
        longitude: longitude,
        deviceInfo: '',
        deviceId: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<RegisterBloc>()),
        BlocProvider(create: (context) => getIt<CityCubit>()..getCities()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        body: BlocConsumer<RegisterBloc, BaseState<RegisterModel>>(
          listener: (context, state) {
            if (state.isSuccess) {
              context.showSuccessMessage(state.data?.message ?? '');
              context.push(AppRouter.verifyOtp, extra: completePhone);
            }
            if (state.isFailure) {
              context.showErrorMessage(state.errorMessage ?? '');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
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
                    ),
                    Gap(20.h),
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

                    // Phone Field
                    CustomPhoneField(
                      onChanged: (phone) =>
                          completePhone = phone.completeNumber,
                      validator: (phone) =>
                          (phone == null || phone.isEmpty)
                              ? 'phoneNumberEmpty'.tr()
                              : null,
                    ),
                    Gap(10.h),

                    // City Dropdown
                    BlocBuilder<CityCubit, BaseState<CityModel>>(
                      builder: (context, cityState) {
                        return CustomDropdown<CityModel>(
                          hint: cityState.isLoading
                              ? 'loading_cities'
                              : 'select_city',
                          value: selectedCity,
                          items: cityState.items
                              .map(
                                (city) => DropdownMenuItem<CityModel>(
                                  value: city,
                                  child: Text(city.name),
                                ),
                              )
                              .toList(),
                          onChanged: (city) =>
                              setState(() => selectedCity = city),
                        );
                      },
                    ),
                    Gap(10.h),

                    // Address + current location
                    LocationPickerField(
                      controller: addressController,
                      onLocationPicked: (lat, lng) {
                        latitude = lat;
                        longitude = lng;
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
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                            () => obscureConfirmPassword =
                                !obscureConfirmPassword,
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
                    state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                        : CustomButton(
                            onPressed: () => _onSubmit(context),
                            title: "sign_up".tr(),
                          ),
                    Gap(20.h),
                    DividerWidget(text: "or".tr()),
                    Gap(20.h),

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
            );
          },
        ),
      ),
    );
  }
}
