import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_type_icon.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/default_address_badge.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

/// اللي اليوزر اختاره من شيت العناوين
class AddressPick {
  /// null معناها "موقعي الحالي"
  final SavedAddressModel? address;

  const AddressPick.currentLocation() : address = null;

  const AddressPick.saved(SavedAddressModel this.address);
}

/// شيت اختيار عنوان من المحفوظين، بيستخدمه الهيدر (تغيير العنوان اللي المغاسل
/// بتتجاب بيه) وتأكيد الطلب (اختيار عنوان الاستلام). الشيت بيرجع الاختيار بس،
/// واللي فاتحه هو اللي بيقرر يعمل بيه إيه
class SavedAddressPickerSheet extends StatefulWidget {
  /// العنوان المختار دلوقتي وعليه العلامة
  final int? selectedId;

  /// الهيدر بيعرض "موقعي الحالي" فوق العناوين، وتأكيد الطلب لأ
  /// لأن الطلب لازم يروح على عنوان محفوظ
  final bool showCurrentLocation;

  /// "موقعي الحالي" هو المختار دلوقتي (الهيدر شغال بالـ GPS)
  final bool currentLocationSelected;

  /// تأكيد الطلب بيختار العنوان اللي لسه متضاف على طول، أما الهيدر فبيسيب
  /// الافتراضي زي ما اليوزر حدده في الفورم
  final bool pickAddedAddress;

  /// الهيدر بيعرض لينك لشاشة عناويني عشان التعديل والحذف
  final bool showManageLink;

  const SavedAddressPickerSheet({
    super.key,
    this.selectedId,
    this.showCurrentLocation = false,
    this.currentLocationSelected = false,
    this.pickAddedAddress = false,
    this.showManageLink = false,
  });

  /// بيرجع null لو قفل الشيت من غير ما يختار
  static Future<AddressPick?> show(
    BuildContext context, {
    int? selectedId,
    bool showCurrentLocation = false,
    bool currentLocationSelected = false,
    bool pickAddedAddress = false,
    bool showManageLink = false,
  }) {
    return showModalBottomSheet<AddressPick>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SavedAddressPickerSheet(
        selectedId: selectedId,
        showCurrentLocation: showCurrentLocation,
        currentLocationSelected: currentLocationSelected,
        pickAddedAddress: pickAddedAddress,
        showManageLink: showManageLink,
      ),
    );
  }

  @override
  State<SavedAddressPickerSheet> createState() =>
      _SavedAddressPickerSheetState();
}

class _SavedAddressPickerSheetState extends State<SavedAddressPickerSheet> {
  /// singleton في get_it فمش بيتعمله close هنا
  final SavedAddressesCubit _cubit = getIt<SavedAddressesCubit>();
  final LocationController _location = getIt<LocationController>();

  @override
  void initState() {
    super.initState();
    // اللي متحمل بيتعرض على طول، والجديد بيوصل في الخلفية
    _cubit.load();
  }

  Future<void> _addAddress() async {
    final added = await context.push<SavedAddressModel>(AppRouter.addressForm);
    if (added == null || !mounted) return;
    // غير كده الشيت بيفضل مفتوح والعنوان الجديد بيظهر في الليستة
    if (widget.pickAddedAddress) {
      Navigator.of(context).pop(AddressPick.saved(added));
    }
  }

  void _openManage() {
    // الشيت بيتقفل الأول عشان لما يرجع من عناويني يلاقي الهوم مش شيت قديم
    // والراوتر بيتمسك قبل القفل عشان الـ context بتاع الشيت رايح
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(AppRouter.savedAddresses);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.8),
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
            _buildHeader(),
            Divider(height: 1, color: AppColors.borderColor),
            Flexible(child: _buildOptions()),
            _buildFooter(),
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 6.h, 8.w, 10.h),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text('choose_address'.tr(), style: TextStyles.darkBold16),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.close, size: 20.r, color: AppColors.greyColor2),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return BlocBuilder<SavedAddressesCubit, BaseState<SavedAddressModel>>(
      bloc: _cubit,
      builder: (context, state) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            if (widget.showCurrentLocation) ...[
              _buildCurrentLocationOption(),
              SizedBox(height: 10.h),
            ],
            ..._buildAddressOptions(state),
          ],
        );
      },
    );
  }

  Widget _buildCurrentLocationOption() {
    return AnimatedBuilder(
      animation: _location,
      builder: (context, _) {
        final subtitle = _location.hasCurrentLocation
            ? _location.currentLocationAddress
            : 'use_current_location'.tr();
        return _AddressOption(
          leading: AddressTypeIcon(
            icon: Icons.my_location,
            highlighted: widget.currentLocationSelected,
          ),
          title: 'current_location'.tr(),
          subtitle: subtitle,
          selected: widget.currentLocationSelected,
          onTap: () =>
              Navigator.of(context).pop(const AddressPick.currentLocation()),
        );
      },
    );
  }

  List<Widget> _buildAddressOptions(BaseState<SavedAddressModel> state) {
    if (state.items.isEmpty) {
      if (state.isLoading || !_cubit.hasLoaded && !state.isFailure) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          ),
        ];
      }
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              Text(
                state.isFailure
                    ? state.errorMessage ?? 'try_again'.tr()
                    : 'no_saved_addresses'.tr(),
                style: TextStyles.darkBold14,
                textAlign: TextAlign.center,
              ),
              if (state.isFailure)
                TextButton(
                  onPressed: _cubit.load,
                  child: Text(
                    'try_again'.tr(),
                    style: TextStyles.boldStyle(
                      14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ];
    }

    return [
      for (final address in state.items) ...[
        _AddressOption(
          leading: AddressTypeIcon(
            address: address,
            highlighted: address.id == widget.selectedId,
          ),
          title: address.displayTitle,
          subtitle: address.address,
          isDefault: address.isDefault,
          selected:
              !widget.currentLocationSelected &&
              address.id == widget.selectedId,
          onTap: () => Navigator.of(context).pop(AddressPick.saved(address)),
        ),
        SizedBox(height: 10.h),
      ],
    ];
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _addAddress,
              icon: Icon(
                Icons.add_location_alt_outlined,
                size: 19.r,
                color: AppColors.primaryColor,
              ),
              label: Text(
                'add_new_address'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          if (widget.showManageLink) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: _openManage,
              child: Text(
                'manage_addresses'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: AppColors.greyColor2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// سطر اختيار في الشيت: أيقونة واسم وعنوان، وعلامة اختيار في الآخر
class _AddressOption extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final bool selected;
  final bool isDefault;
  final VoidCallback onTap;

  const _AddressOption({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isDefault = false,
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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              leading,
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyles.darkBold14.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDefault) ...[
                          SizedBox(width: 8.w),
                          const DefaultAddressBadge(),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
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
