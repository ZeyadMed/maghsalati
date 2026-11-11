import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/common_widget/custom_success_message.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/map_picker_screen.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_map_preview.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/save_address_cubit.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

/// نوع اسم العنوان: Home و Work بيتبعتوا زي ما هم، و other بيتبعت النص اللي كتبه
enum _TitleType { home, work, other }

/// فورم إضافة عنوان أو تعديله: المكان من الخريطة، والعنوان المكتوب،
/// والاسم، والتفاصيل الإضافية، وهل هو الافتراضي
/// بيرجع العنوان بعد الحفظ (زي ما رجع في الليستة) للشاشة اللي فتحته
class AddressFormScreen extends StatefulWidget {
  /// null في الإضافة
  final SavedAddressModel? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SaveAddressCubit _saveCubit = getIt<SaveAddressCubit>();
  final SavedAddressesCubit _addresses = getIt<SavedAddressesCubit>();

  late final TextEditingController _addressController;
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;

  late _TitleType _titleType;
  double? _latitude;
  double? _longitude;
  late bool _isDefault;

  /// آخر عنوان اتحط من الخريطة، عشان لو اختار مكان تاني نبدله
  /// إلا لو اليوزر عدّل النص بإيده، ساعتها نسيب اللي كتبه
  String? _lastPickedAddress;

  /// رسالة "حدد الموقع" بتظهر بعد أول محاولة حفظ بس
  bool _showLocationError = false;

  bool get _isEditing => widget.address != null;

  /// الافتراضي مابيتلغيش من التعديل (السيرفر بيتجاهل false)،
  /// والتغيير بيبقى باختيار عنوان تاني كافتراضي
  bool get _isCurrentDefault => widget.address?.isDefault ?? false;

  /// أول عنوان بيبقى افتراضي تلقائيًا حتى لو مابعتناش true
  bool get _isFirstAddress =>
      !_isEditing && _addresses.hasLoaded && _addresses.state.items.isEmpty;

  bool get _isDefaultLocked => _isCurrentDefault || _isFirstAddress;

  bool get _hasLocation => _latitude != null && _longitude != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _addressController = TextEditingController(text: address?.address);
    _detailsController = TextEditingController(
      text: address?.additionalDetails,
    );
    _latitude = address?.latitude;
    _longitude = address?.longitude;
    _isDefault = address?.isDefault ?? false;

    if (address == null || address.isHome) {
      _titleType = _TitleType.home;
      _titleController = TextEditingController();
    } else if (address.isWork) {
      _titleType = _TitleType.work;
      _titleController = TextEditingController();
    } else {
      _titleType = _TitleType.other;
      _titleController = TextEditingController(text: address.title);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _titleController.dispose();
    _detailsController.dispose();
    _saveCubit.close();
    super.dispose();
  }

  /// بتفتح الخريطة على مكان العنوان، أو على الموقع الحالي لو لسه مفيش
  Future<void> _pickOnMap() async {
    final location = getIt<LocationController>();
    final initialLatitude = _latitude ?? location.latitude;
    final initialLongitude = _longitude ?? location.longitude;

    final picked = await context.push<PickedLocation>(
      AppRouter.mapPicker,
      extra: initialLatitude == null || initialLongitude == null
          ? null
          : PickedLocation(
              latitude: initialLatitude,
              longitude: initialLongitude,
            ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _latitude = picked.latitude;
      _longitude = picked.longitude;
      _showLocationError = false;

      // العنوان من الخريطة قيمة مبدئية، واليوزر يقدر يعدلها بعدين
      final current = _addressController.text.trim();
      final userEdited = current.isNotEmpty && current != _lastPickedAddress;
      if (picked.address.isNotEmpty && !userEdited) {
        // السيرفر بيقبل 500 حرف بالكتير، وعناوين Nominatim ممكن تبقى طويلة
        final text =
            picked.address.length > SavedAddressRequest.addressMaxLength
            ? picked.address.substring(0, SavedAddressRequest.addressMaxLength)
            : picked.address;
        _addressController.text = text;
        _lastPickedAddress = text;
      }
    });
  }

  void _onSave() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final locationError = _locationError();
    setState(() => _showLocationError = locationError != null);
    if (!formValid || locationError != null) return;

    _saveCubit.save(
      SavedAddressRequest(
        title: switch (_titleType) {
          _TitleType.home => SavedAddressModel.homeTitle,
          _TitleType.work => SavedAddressModel.workTitle,
          _TitleType.other => _titleController.text.trim(),
        },
        address: _addressController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        additionalDetails: _detailsController.text,
        isDefault: _isDefaultLocked || _isDefault,
      ),
      addressId: widget.address?.id,
    );
  }

  /// نفس قواعد السيرفر: الموقع مطلوب والإحداثيات جوه النطاق
  String? _locationError() {
    if (!_hasLocation) return 'address_location_required'.tr();
    if (!SavedAddressRequest.isValidLatitude(_latitude!) ||
        !SavedAddressRequest.isValidLongitude(_longitude!)) {
      return 'invalid_coordinates'.tr();
    }
    return null;
  }

  void _onSaveStateChanged(
    BuildContext context,
    BaseState<SavedAddressModel> state,
  ) {
    if (state.isSuccess) {
      // الأوفرلاي بيتحط على طول فبيفضل ظاهر بعد ما الشاشة تتقفل
      CustomSuccessOverlay.show(
        context: context,
        text: _isEditing ? 'address_updated' : 'address_added',
      );
      context.pop(state.data);
    } else if (state.isFailure) {
      // رسالة السيرفر بتتعرض زي ما هي (زي أخطاء الـ 400)
      context.showErrorMessage(state.errorMessage ?? 'try_again'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaveAddressCubit, BaseState<SavedAddressModel>>(
      bloc: _saveCubit,
      listener: _onSaveStateChanged,
      child: Scaffold(
        appBar: CustomAppBar(
          title: _isEditing ? 'edit_address' : 'add_address',
          backgroundColor: AppColors.scaffoldBackgroundColor,
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
                    labelKey: 'address_location',
                    child: _buildLocationCard(),
                  ),
                  SizedBox(height: 18.h),
                  _buildLabeled(
                    labelKey: 'full_address',
                    child: Customtextfield(
                      hintText: 'full_address_hint',
                      textEditingController: _addressController,
                      validator: _addressValidator,
                      keyboardType: TextInputType.streetAddress,
                      maxLines: 3,
                      minLines: 1,
                      borderRadious: 14.r,
                      hieght: 16.h,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildLabeled(
                    labelKey: 'address_title',
                    child: _buildTitlePicker(),
                  ),
                  SizedBox(height: 18.h),
                  _buildLabeled(
                    labelKey: 'additional_details',
                    child: Customtextfield(
                      hintText: 'additional_details_hint',
                      textEditingController: _detailsController,
                      validator: _detailsValidator,
                      maxLines: 3,
                      minLines: 2,
                      borderRadious: 14.r,
                      hieght: 14.h,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildDefaultSwitch(),
                  SizedBox(height: 28.h),
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

  /// خريطة صغيرة عليها المكان المختار، ولو لسه مفيش زرار يفتح الخريطة
  Widget _buildLocationCard() {
    final borderColor = _showLocationError
        ? AppColors.redColor2
        : AppColors.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.whiteColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(color: borderColor),
          ),
          child: InkWell(
            onTap: _pickOnMap,
            child: _hasLocation
                ? Stack(
                    children: [
                      AddressMapPreview(
                        latitude: _latitude!,
                        longitude: _longitude!,
                      ),
                      PositionedDirectional(
                        bottom: 10.h,
                        end: 10.w,
                        child: _buildChangeLocationChip(),
                      ),
                    ],
                  )
                : _buildPickLocationPlaceholder(),
          ),
        ),
        if (_showLocationError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 12.w),
            child: Text(
              _locationError() ?? '',
              style: TextStyles.darkRegular12.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPickLocationPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
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
          SizedBox(width: 12.w),
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
          SizedBox(width: 4.w),
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

  /// المنزل والعمل جاهزين، و"آخر" بيفتح خانة يكتب فيها الاسم اللي عايزه
  Widget _buildTitlePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildTitleChip(
              _TitleType.home,
              Icons.home_outlined,
              'address_title_home',
            ),
            _buildTitleChip(
              _TitleType.work,
              Icons.work_outline_rounded,
              'address_title_work',
            ),
            _buildTitleChip(
              _TitleType.other,
              Icons.location_on_outlined,
              'address_title_other',
            ),
          ],
        ),
        if (_titleType == _TitleType.other) ...[
          SizedBox(height: 4.h),
          Customtextfield(
            hintText: 'address_title_hint',
            textEditingController: _titleController,
            validator: _titleValidator,
            borderRadious: 14.r,
            hieght: 14.h,
          ),
        ],
      ],
    );
  }

  Widget _buildTitleChip(_TitleType type, IconData icon, String labelKey) {
    final selected = _titleType == type;
    final color = selected ? AppColors.whiteColor : AppColors.darkTextColor;
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _titleType = type),
      avatar: Icon(icon, size: 18.r, color: color),
      label: Text(labelKey.tr()),
      labelStyle: TextStyles.darkRegular14.copyWith(color: color),
      selectedColor: AppColors.primaryColor,
      backgroundColor: AppColors.whiteColor,
      side: BorderSide(
        color: selected ? AppColors.primaryColor : AppColors.borderColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
    );
  }

  /// لو العنوان افتراضي أصلًا أو أول عنوان، السويتش بيتقفل على true
  /// لأن السيرفر مش هيشيل الافتراضي، ومعاه سطر بيوضح السبب
  Widget _buildDefaultSwitch() {
    final locked = _isDefaultLocked;
    final hintKey = _isCurrentDefault
        ? 'default_address_locked_hint'
        : _isFirstAddress
        ? 'first_address_default_hint'
        : 'default_address_desc';

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 10.h, 8.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'make_default_address'.tr(),
                  style: TextStyles.darkBold14.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(4.h),
                Text(
                  hintKey.tr(),
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor3,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: locked || _isDefault,
            onChanged: locked
                ? null
                : (value) => setState(() => _isDefault = value),
            activeTrackColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  /// الزرار بيتحول لودر وقت الطلب عشان مايتبعتش مرتين
  Widget _buildSaveButton() {
    return BlocBuilder<SaveAddressCubit, BaseState<SavedAddressModel>>(
      bloc: _saveCubit,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        return CustomButton(
          title: 'save_address',
          onPressed: _onSave,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          borderRadius: 14.r,
        );
      },
    );
  }

  String? _addressValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'address_required'.tr();
    return _maxLength(text, SavedAddressRequest.addressMaxLength);
  }

  String? _titleValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'address_title_required'.tr();
    return _maxLength(text, SavedAddressRequest.titleMaxLength);
  }

  String? _detailsValidator(String? value) {
    return _maxLength(
      value?.trim() ?? '',
      SavedAddressRequest.detailsMaxLength,
    );
  }

  String? _maxLength(String text, int max) {
    if (text.length <= max) return null;
    return 'max_length_error'.tr(args: ['$max']);
  }
}
