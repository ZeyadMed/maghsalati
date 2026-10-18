import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:maghsalati/core/style/app_colors.dart';

import 'dart:ui' as ui;

import 'package:maghsalati/core/theme/text_styles.dart';

class CustomPhoneField extends StatelessWidget {
  final void Function(PhoneNumber)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  /// ليبيا هي الدولة الوحيدة المسموح بيها
  static final List<Country> _allowedCountries = countries
      .where((country) => country.code == 'LY')
      .toList();

  const CustomPhoneField({
    super.key,
    this.onChanged,
    this.validator,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // الباكدج مابتندهش الـ validator بتاعنا وقت validate() لو الحقل فاضي
    // ومحدش لمسه، فالحقل كان بيعدي فاضي. الـ FormField ده بيندهه دايماً
    // وبيعرض الغلط في نفس مكان غلط الباكدج. الرقم الناقص بيمسكه فحص الطول
    // اللي في الباكدج (9 أرقام لليبيا)
    return FormField<String>(
      initialValue: controller?.text ?? '',
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Directionality(
        textDirection: ui.TextDirection.ltr,
        child: IntlPhoneField(
          controller: controller,
          initialCountryCode: 'LY',
          countries: _allowedCountries,
          showDropdownIcon: false,
          style: TextStyles.darkRegular16,
          dropdownTextStyle: TextStyles.darkRegular16,
          dropdownDecoration: const BoxDecoration(),
          disableLengthCheck: false,
          disableAutoFillHints: false,
          keyboardType: TextInputType.phone,
          inputFormatters: [_PhoneDigitsFormatter()],
          languageCode: 'ar',
          pickerDialogStyle: PickerDialogStyle(
            countryNameStyle: TextStyles.blackBold16,
            countryCodeStyle: TextStyles.blackBold14,
            searchFieldPadding: const EdgeInsets.all(5),
          ),
          invalidNumberMessage: "invalidPhoneNumber".tr(),
          onChanged: (phone) {
            field.didChange(phone.number);
            onChanged?.call(phone);
          },
          decoration: InputDecoration(
            errorText: field.errorText,
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 20.w,
            ),
            hintText: "9XXXXXXXX",
            fillColor: AppColors.whiteColor.withValues(alpha: 0.9),
            filled: true,
            hintStyle: TextStyles.greyColor2Regular14.copyWith(
              // color: const Color(0xff8b7454),
              fontSize: 14.sp,
            ),
            // prefixIconColor: const Color(0xff8b7454),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 0.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            ),
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// الكيبورد العربي بيكتب ٠-٩، والباكدج بيفحص الطول بـ int.tryParse اللي
/// مابيفهمهاش فالرقم الناقص كان بيعدي. فبنحولها لإنجليزي ونشيل أي حاجة
/// غير الأرقام، ونشيل الصفر اللي في الأول عشان 091... تبقى 91... بدل ما
/// الحد الأقصى (9) يقص آخر رقم
class _PhoneDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (final rune in newValue.text.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.writeCharCode(rune);
      } else if (rune >= 0x660 && rune <= 0x669) {
        buffer.writeCharCode(rune - 0x660 + 0x30);
      } else if (rune >= 0x6F0 && rune <= 0x6F9) {
        buffer.writeCharCode(rune - 0x6F0 + 0x30);
      }
    }
    final digits = buffer.toString().replaceFirst(RegExp(r'^0+'), '');
    if (digits == newValue.text) return newValue;

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
