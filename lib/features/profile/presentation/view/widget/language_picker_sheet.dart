import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// شيت اختيار لغة الأبلكيشن، بيرجع كود اللغة اللي اتختارت بس
/// واللي فاتحه هو اللي بيغير اللغة
class LanguagePickerSheet extends StatelessWidget {
  /// اللغات المدعومة بأسمائها الأصلية، فبتتعرض زي ما هي في أي لغة
  static const Map<String, String> languages = {
    'ar': 'العربية',
    'en': 'English',
  };

  /// كود اللغة الحالية وعليها العلامة
  final String selectedCode;

  const LanguagePickerSheet({super.key, required this.selectedCode});

  /// بيرجع null لو قفل الشيت من غير ما يختار
  static Future<String?> show(
    BuildContext context, {
    required String selectedCode,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguagePickerSheet(selectedCode: selectedCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHandle(),
            _buildHeader(context),
            Divider(height: 1, color: AppColors.borderColor),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Column(
                children: [
                  for (final entry in languages.entries) ...[
                    if (entry.key != languages.keys.first)
                      SizedBox(height: 10.h),
                    _LanguageOption(
                      name: entry.value,
                      selected: entry.key == selectedCode,
                      onTap: () => Navigator.of(context).pop(entry.key),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
        width: 44.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.greyColor5,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 6.h, 8.w, 10.h),
      child: Row(
        children: [
          Icon(
            Icons.translate_rounded,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text('choose_language'.tr(), style: TextStyles.darkBold16),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.close, size: 20.r, color: AppColors.greyColor2),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryColor.withValues(alpha: 0.06)
          : AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: selected ? AppColors.primaryColor : AppColors.borderColor,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyles.darkBold14.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 22.r,
                color: selected ? AppColors.primaryColor : AppColors.greyColor5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
