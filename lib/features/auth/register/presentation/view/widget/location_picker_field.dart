import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/helpers/location_service.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/map_picker_screen.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_map_preview.dart';

/// خانة العنوان ومعاها كارت الخريطة وزرار "حدد موقعي الحالي"
/// اليوزر يقدر يختار المكان من الخريطة أو ياخد موقع الـ GPS على طول،
/// والعنوان المقروء بيتحط في الخانة وهو يقدر يعدل النص بعدها عادي
class LocationPickerField extends StatefulWidget {
  final TextEditingController controller;

  /// بترجع الإحداثيات للشاشة عشان تبعتها مع بيانات التسجيل
  final void Function(double latitude, double longitude) onLocationPicked;

  /// الموقع المتحدد قبل كده (زي تعديل الملف الشخصي) عشان الكارت يعرضه
  final double? initialLatitude;
  final double? initialLongitude;

  /// لو true الفورم مابيعديش غير لما الموقع يتحدد (من الخريطة أو الـ GPS)
  final bool isRequired;

  const LocationPickerField({
    super.key,
    required this.controller,
    required this.onLocationPicked,
    this.initialLatitude,
    this.initialLongitude,
    this.isRequired = false,
  });

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  final LocationService _locationService = LocationService();

  /// كارت الخريطة جوه FormField عشان validate بتاع الفورم يشيك على الموقع
  final _mapFieldKey = GlobalKey<FormFieldState<bool>>();

  bool _isLoading = false;

  double? _latitude;
  double? _longitude;

  /// آخر عنوان اتحط من الخريطة أو الـ GPS، عشان لو اختار مكان تاني نبدله
  /// إلا لو اليوزر عدّل النص بإيده، ساعتها نسيب اللي كتبه
  late String _lastPickedAddress = widget.controller.text.trim();

  bool get _hasLocation => _latitude != null && _longitude != null;

  @override
  void initState() {
    super.initState();
    // 0,0 معناها إن الموقع ماتحددش قبل كده مش نقطة حقيقية
    final lat = widget.initialLatitude;
    final lng = widget.initialLongitude;
    if (lat != null && lng != null && (lat != 0 || lng != 0)) {
      _latitude = lat;
      _longitude = lng;
    }
  }

  void _applyLocation(double latitude, double longitude, String address) {
    widget.onLocationPicked(latitude, longitude);
    setState(() {
      _latitude = latitude;
      _longitude = longitude;

      final current = widget.controller.text.trim();
      final userEdited = current.isNotEmpty && current != _lastPickedAddress;
      if (address.isNotEmpty && !userEdited) {
        widget.controller.text = address;
        _lastPickedAddress = address;
      }
    });
    // بيعيد الـ validation فرسالة "حدد الموقع" تختفي أول ما يختار
    _mapFieldKey.currentState?.didChange(true);
  }

  /// بتفتح الخريطة على المكان المختار، أو على الافتراضي لو لسه مفيش
  Future<void> _pickOnMap() async {
    final picked = await context.push<PickedLocation>(
      AppRouter.mapPicker,
      extra: _hasLocation
          ? PickedLocation(latitude: _latitude!, longitude: _longitude!)
          : null,
    );
    if (picked == null || !mounted) return;

    _applyLocation(picked.latitude, picked.longitude, picked.address);
  }

  Future<void> _pickCurrentLocation() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final result = await _locationService.getCurrentAddress();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess && result.latitude != null) {
      _applyLocation(result.latitude!, result.longitude!, result.address);
      return;
    }

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        Gap(10.h),
        FormField<bool>(
          key: _mapFieldKey,
          initialValue: _hasLocation,
          // الرسالة مابتظهرش غير بعد أول محاولة submit، وبتختفي مع الاختيار
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (hasLocation) => widget.isRequired && hasLocation != true
              ? 'address_location_required'.tr()
              : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMapCard(hasError: field.hasError),
              if (field.hasError) ...[
                Gap(6.h),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 12.w),
                  child: Text(
                    field.errorText ?? '',
                    style: TextStyles.darkRegular12.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Gap(10.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _buildCurrentLocationButton(),
        ),
      ],
    );
  }

  /// خريطة صغيرة عليها المكان المختار، ولو لسه مفيش زرار يفتح الخريطة
  Widget _buildMapCard({required bool hasError}) {
    return Material(
      color: AppColors.whiteColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: hasError ? Colors.red : AppColors.borderColor),
      ),
      child: InkWell(
        onTap: _pickOnMap,
        child: _hasLocation
            ? Stack(
                children: [
                  AddressMapPreview(
                    latitude: _latitude!,
                    longitude: _longitude!,
                    height: 130.h,
                  ),
                  PositionedDirectional(
                    bottom: 10.h,
                    end: 10.w,
                    child: _buildChangeLocationChip(),
                  ),
                ],
              )
            : _buildPickOnMapPlaceholder(),
      ),
    );
  }

  Widget _buildPickOnMapPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.map_outlined,
              size: 22.r,
              color: AppColors.primaryColor,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Text(
              'pick_on_map'.tr(),
              style: TextStyles.darkBold14.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.r,
            color: AppColors.greyColor5,
          ),
        ],
      ),
    );
  }

  Widget _buildChangeLocationChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_location_alt_outlined,
            size: 16.r,
            color: AppColors.primaryColor,
          ),
          Gap(4.w),
          Text(
            'change_location'.tr(),
            style: TextStyles.darkBold12.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return GestureDetector(
      onTap: _pickCurrentLocation,
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
            Icon(Icons.my_location, size: 18.sp, color: AppColors.primaryColor),
          Gap(6.w),
          Text(
            _isLoading ? 'locating'.tr() : 'use_current_location'.tr(),
            style: TextStyles.blackBold14.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
