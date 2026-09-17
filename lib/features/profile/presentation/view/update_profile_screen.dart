import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/common_widget/custom_success_message.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';

/// شاشة تعديل الملف الشخصي: الاسم والتليفون والإيميل
/// لما يدوس حفظ بترجع الـ [UserModel] المعدل لشاشة حسابي عشان تتحدث
class UpdateProfileScreen extends StatefulWidget {
  final UserModel user;

  const UpdateProfileScreen({super.key, required this.user});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  /// الرقم كامل بكود الدولة زي ما بييجي من الحقل (+218911234567)
  /// بيتحدث مع كل تغيير، وبنستخدمه وقت الحفظ بدل نص الكنترولر
  /// عشان نص الكنترولر بيبقى الرقم المحلي من غير كود الدولة
  late String _completePhone;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    // IntlPhoneField بياخد الرقم المحلي من غير كود دولة ولا مسافات
    _phoneController = TextEditingController(
      text: _toNationalNumber(widget.user.phone),
    );
    _emailController = TextEditingController(text: widget.user.email);
    _completePhone = widget.user.phone;
  }

  /// بتحضر الرقم المحفوظ عشان يتعرض في الحقل:
  /// بتشيل المسافات وكود الدولة والصفر اللي في الأول
  String _toNationalNumber(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+218')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('218')) {
      digits = digits.substring(3);
    }
    digits = digits.replaceAll('+', '');
    return digits.startsWith('0') ? digits.substring(1) : digits;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// بيتحقق من الحقول الأول، وبعدين بيرجع النسخة المعدلة للشاشة اللي فتحته
  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      phone: _completePhone.trim(),
      email: _emailController.text.trim(),
    );

    CustomSuccessOverlay.show(
      context: context,
      text: 'profile_updated'.tr(),
    );
    context.pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _buildField(
                  labelKey: 'full_name',
                  controller: _nameController,
                  hintKey: 'full_name',
                  validator: _nameValidator,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 18.h),
                _buildPhoneField(),
                SizedBox(height: 18.h),
                _buildField(
                  labelKey: 'email',
                  controller: _emailController,
                  hintKey: 'email',
                  validator: _emailValidator,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  title: 'save_changes',
                  onPressed: _onSave,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  borderRadius: 14.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// عنوان فوق الحقل وتحته الحقل نفسه بخلفية بيضا زي الصورة
  Widget _buildField({
    required String labelKey,
    required String hintKey,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          labelKey.tr(),
          style: TextStyles.darkBold14.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Customtextfield(
          hintText: hintKey,
          textEditingController: controller,
          validator: validator,
          keyboardType: keyboardType,
          borderRadious: 14.r,
          hieght: 16.h,
        ),
      ],
    );
  }

  /// حقل التليفون بكود الدولة، بنفس شكل اللي في شاشة إنشاء الحساب
  /// الحقل نفسه بيتحقق من طول الرقم حسب الدولة المختارة
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'phone_number'.tr(),
          style: TextStyles.darkBold14.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        CustomPhoneField(
          controller: _phoneController,
          onChanged: (phone) => _completePhone = phone.completeNumber,
        ),
      ],
    );
  }

  /// الاسم مايكونش فاضي ويكون بين 3 و 30 حرف
  String? _nameValidator(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'nameMustBeNotEmpty'.tr();
    if (name.length < 3 || name.length > 30) return 'invalidName'.tr();
    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'emailMustBeNotEmpty'.tr();
    if (!RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(email)) {
      return 'enter_vaild_email'.tr();
    }
    return null;
  }
}
