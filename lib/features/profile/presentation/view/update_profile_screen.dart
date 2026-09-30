import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/common_widget/custom_error_message.dart';
import 'package:maghsalati/core/common_widget/custom_success_message.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_drop_down.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/auth/register/models/city_model.dart';
import 'package:maghsalati/features/auth/register/presentation/logic/city_cubit.dart';
import 'package:maghsalati/features/auth/register/presentation/view/widget/location_picker_field.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/presentation/view_model/update_profile_cubit.dart';

/// شاشة تعديل الملف الشخصي: الاسم والمدينة والعنوان والموقع
/// بتبعتهم لـ PUT api/customer/profile، ولما ينجح بترجع الـ [UserModel]
/// المعدل لشاشة حسابي عشان تتحدث
class UpdateProfileScreen extends StatefulWidget {
  final UserModel user;

  const UpdateProfileScreen({super.key, required this.user});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UpdateProfileCubit _updateCubit = getIt<UpdateProfileCubit>();
  final CityCubit _cityCubit = getIt<CityCubit>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  /// بتتملى بمدينة المستخدم الحالية أول ما المدن توصل
  CityModel? _selectedCity;

  /// بتفضل الإحداثيات القديمة لحد ما المستخدم يحدد موقعه الحالي
  late double _latitude = widget.user.latitude;
  late double _longitude = widget.user.longitude;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _addressController = TextEditingController(text: widget.user.address);
    _cityCubit.getCities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _updateCubit.close();
    _cityCubit.close();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final city = _selectedCity;
    if (city == null) {
      CustomErrorOverlay.show(context: context, text: 'select_city_first'.tr());
      return;
    }

    _updateCubit.updateProfile(
      widget.user.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        cityId: city.id,
        cityName: city.name,
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
  }

  void _onUpdateStateChanged(BuildContext context, BaseState<UserModel> state) {
    if (state.isSuccess) {
      CustomSuccessOverlay.show(
        context: context,
        text: 'profile_updated'.tr(),
      );
      context.pop(state.data);
    } else if (state.isFailure) {
      CustomErrorOverlay.show(
        context: context,
        text: state.errorMessage ?? 'try_again'.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateProfileCubit, BaseState<UserModel>>(
      bloc: _updateCubit,
      listener: _onUpdateStateChanged,
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: CustomAppBar(
          title: 'edit_profile',
          backgroundColor: AppColors.secondaryColor,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabeled(
                    labelKey: 'full_name',
                    child: Customtextfield(
                      hintText: 'full_name',
                      textEditingController: _nameController,
                      validator: _nameValidator,
                      keyboardType: TextInputType.name,
                      borderRadious: 14.r,
                      hieght: 16.h,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildLabeled(labelKey: 'city', child: _buildCityDropdown()),
                  SizedBox(height: 18.h),
                  _buildLabeled(
                    labelKey: 'address',
                    child: LocationPickerField(
                      controller: _addressController,
                      onLocationPicked: (lat, lng) {
                        _latitude = lat;
                        _longitude = lng;
                      },
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// عنوان فوق الحقل وتحته الحقل نفسه
  Widget _buildLabeled({required String labelKey, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          labelKey.tr(),
          style: TextStyles.darkBold14.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  /// أول ما المدن توصل بنختار مدينة المستخدم الحالية من الليستة
  Widget _buildCityDropdown() {
    return BlocConsumer<CityCubit, BaseState<CityModel>>(
      bloc: _cityCubit,
      listenWhen: (_, state) => state.isSuccess && _selectedCity == null,
      listener: (context, state) {
        final current = state.items
            .where((city) => city.id == widget.user.cityId)
            .firstOrNull;
        if (current != null) setState(() => _selectedCity = current);
      },
      builder: (context, state) {
        return CustomDropdown<CityModel>(
          hint: state.isLoading ? 'loading_cities' : 'select_city',
          value: _selectedCity,
          items: state.items
              .map(
                (city) => DropdownMenuItem<CityModel>(
                  value: city,
                  child: Text(city.name),
                ),
              )
              .toList(),
          onChanged: (city) => setState(() => _selectedCity = city),
        );
      },
    );
  }

  /// الزرار بيتحول لودر وقت الطلب عشان مايتبعتش مرتين
  Widget _buildSaveButton() {
    return BlocBuilder<UpdateProfileCubit, BaseState<UserModel>>(
      bloc: _updateCubit,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        return CustomButton(
          title: 'save_changes',
          onPressed: _onSave,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          borderRadius: 14.r,
        );
      },
    );
  }

  /// الاسم مايكونش فاضي ويكون بين 3 و 30 حرف
  String? _nameValidator(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'nameMustBeNotEmpty'.tr();
    if (name.length < 3 || name.length > 30) return 'invalidName'.tr();
    return null;
  }
}
