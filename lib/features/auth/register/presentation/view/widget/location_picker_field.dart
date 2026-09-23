import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/helpers/location_service.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';

/// خانة العنوان ومعاها زرار "حدد موقعي الحالي"
/// الزرار بيجيب الإحداثيات من الـ GPS ويحولها لعنوان مقروء يتحط في الخانة،
/// والمستخدم يقدر يعدل النص بعدها عادي لو العنوان مش مظبوط
class LocationPickerField extends StatefulWidget {
  final TextEditingController controller;

  /// بترجع الإحداثيات للشاشة عشان تبعتها مع بيانات التسجيل
  final void Function(double latitude, double longitude) onLocationPicked;

  const LocationPickerField({
    super.key,
    required this.controller,
    required this.onLocationPicked,
  });

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  final LocationService _locationService = LocationService();

  bool _isLoading = false;

  /// بيبقى true بعد ما الإحداثيات تتجاب، عشان نوري للمستخدم إن الموقع اتحدد
  bool _hasLocation = false;

  Future<void> _pickLocation() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final result = await _locationService.getCurrentAddress();

    if (!mounted) return;

    if (result.isSuccess) {
      widget.controller.text = result.address;
      widget.onLocationPicked(result.latitude ?? 0, result.longitude ?? 0);
      setState(() {
        _hasLocation = true;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);

    // الرفض النهائي أو الـ GPS المقفول محتاجين يروح للإعدادات بنفسه
    if (result.needsSettings) {
      context.showErrorMessage('location_permission_denied'.tr());
      await _locationService.openSettings();
      return;
    }
    if (result.status == LocationStatus.serviceDisabled) {
      context.showErrorMessage('location_service_disabled'.tr());
      await _locationService.openLocationSettings();
      return;
    }
    context.showErrorMessage('location_failed'.tr());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Customtextfield(
          textEditingController: widget.controller,
          hintText: 'address'.tr(),
          keyboardType: TextInputType.streetAddress,
          maxLines: 2,
          minLines: 1,
          prefix: const Icon(Icons.location_on_outlined),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'address_required'.tr()
              : null,
        ),
        Gap(8.h),
        GestureDetector(
          onTap: _pickLocation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                )
              else
                Icon(
                  _hasLocation ? Icons.check_circle : Icons.my_location,
                  size: 18.sp,
                  color: AppColors.primaryColor,
                ),
              Gap(6.w),
              Text(
                _isLoading
                    ? 'locating'.tr()
                    : _hasLocation
                        ? 'location_selected'.tr()
                        : 'use_current_location'.tr(),
                style: TextStyles.blackBold14.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
