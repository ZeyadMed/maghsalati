import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_map_preview.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_type_icon.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/default_address_badge.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

/// أول كارت في تأكيد الطلب: خريطة عليها دبوس عنوان الاستلام، وفوقها من تحت
/// dropdown بالعناوين المحفوظة. العنوان اللي بيتختار للطلب ده بس (مش الافتراضي)
/// والسيرفر بيحسب عليه التوصيل ([onSelect])، ولو مفيش عناوين الزرار بيفتح الإضافة.
/// ولو المغسلة مش بتوصّل للعنوان بيظهر [warning] تحت الخريطة
class CheckoutAddressCard extends StatelessWidget {
  final SavedAddressesCubit addresses;

  /// العنوان المختار للطلب، و null يعني الافتراضي
  final int? selectedId;

  /// السلة بتتحسب على العنوان الجديد، فالليستة مقفولة لحد ما تخلص
  final bool busy;

  /// سبب إن المغسلة مش بتوصّل للعنوان، و null لو بتوصّل
  final String? warning;
  final ValueChanged<SavedAddressModel> onSelect;
  final VoidCallback onAddAddress;

  const CheckoutAddressCard({
    super.key,
    required this.addresses,
    required this.onSelect,
    required this.onAddAddress,
    this.selectedId,
    this.busy = false,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedAddressesCubit, BaseState<SavedAddressModel>>(
      bloc: addresses,
      builder: (context, state) {
        final selected = addresses.addressOrDefault(selectedId);
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: warning != null
                  ? AppColors.redColor2.withValues(alpha: 0.5)
                  : AppColors.borderColor,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 190.h,
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Positioned.fill(child: _buildMap(selected)),
                      PositionedDirectional(
                        start: 12.w,
                        end: 12.w,
                        bottom: 12.h,
                        child: _buildDropdown(
                          state,
                          selected,
                          menuWidth: constraints.maxWidth - 24.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (warning != null) _buildWarning(warning!),
            ],
          ),
        );
      },
    );
  }

  /// المغسلة مش بتوصّل للعنوان ده، فالتأكيد مقفول لحد ما يختار عنوان تاني
  Widget _buildWarning(String text) {
    return Container(
      color: AppColors.redColor2.withValues(alpha: 0.08),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.wrong_location_outlined,
            size: 18.r,
            color: AppColors.redColor2,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyles.darkRegular12.copyWith(
                color: AppColors.redColor2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(SavedAddressModel? address) {
    if (address == null) {
      return Align(
        alignment: const Alignment(0, -0.4),
        child: Icon(
          Icons.map_outlined,
          size: 48.r,
          color: AppColors.primaryColor.withValues(alpha: 0.35),
        ),
      );
    }
    return AddressMapPreview(
      latitude: address.latitude,
      longitude: address.longitude,
      height: 190.h,
    );
  }

  Widget _buildDropdown(
    BaseState<SavedAddressModel> state,
    SavedAddressModel? selected, {
    required double menuWidth,
  }) {
    // لسه بنجيب العناوين أول مرة، فمانقولش إن مفيش عناوين
    final firstLoad = state.items.isEmpty && !addresses.hasLoaded;
    if (firstLoad) {
      return _Pill(title: '...', trailing: _spinner(), onTap: null);
    }

    if (state.items.isEmpty) {
      return _Pill(
        icon: Icons.add_location_alt_outlined,
        title: 'add_pickup_address'.tr(),
        titleColor: AppColors.primaryColor,
        onTap: onAddAddress,
      );
    }

    return MenuAnchor(
      alignmentOffset: Offset(0, 6.h),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.whiteColor),
        surfaceTintColor: const WidgetStatePropertyAll(AppColors.whiteColor),
        elevation: const WidgetStatePropertyAll(6),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6.h)),
        maximumSize: WidgetStatePropertyAll(Size(menuWidth, 320.h)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
      menuChildren: [
        for (final address in state.items)
          _menuItem(
            width: menuWidth,
            onPressed: () => onSelect(address),
            child: _AddressMenuRow(
              address: address,
              selected: address.id == selected?.id,
            ),
          ),
        Divider(height: 1, color: AppColors.borderColor),
        _menuItem(
          width: menuWidth,
          onPressed: onAddAddress,
          child: Row(
            children: [
              Icon(
                Icons.add_location_alt_outlined,
                size: 20.r,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 10.w),
              Text(
                'add_new_address'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
      builder: (context, controller, _) => _Pill(
        icon: Icons.location_on_outlined,
        title: selected?.displayTitle ?? 'choose_address'.tr(),
        subtitle: selected?.address,
        // السلة بتتحسب على العنوان الجديد، فمايفتحش الليستة لحد ما تخلص
        trailing: busy ? _spinner() : null,
        onTap: busy
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Widget _menuItem({
    required double width,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        minimumSize: Size(width, 48.h),
      ),
      child: SizedBox(width: width - 24.w, child: child),
    );
  }

  Widget _spinner() => SizedBox(
    width: 18.r,
    height: 18.r,
    child: const CircularProgressIndicator(
      strokeWidth: 2,
      color: AppColors.primaryColor,
    ),
  );
}

/// الزرار الأبيض اللي على الخريطة: أيقونة واسم العنوان وسهم الليستة
class _Pill extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Pill({
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.titleColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor.withValues(alpha: 0.95),
      elevation: 3,
      shadowColor: AppColors.blackColor.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20.r, color: AppColors.primaryColor),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyles.darkBold14.copyWith(color: titleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        style: TextStyles.darkRegular12.copyWith(
                          color: AppColors.greyColor3,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              trailing ??
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.r,
                    color: AppColors.darkTextColor,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// سطر عنوان في الليستة، والمختار (الافتراضي) عليه علامة
class _AddressMenuRow extends StatelessWidget {
  final SavedAddressModel address;
  final bool selected;

  const _AddressMenuRow({required this.address, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AddressTypeIcon(address: address, highlighted: selected),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      address.displayTitle,
                      style: TextStyles.darkBold14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (address.isDefault) ...[
                    SizedBox(width: 6.w),
                    const DefaultAddressBadge(),
                  ],
                ],
              ),
              Text(
                address.address,
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (selected) ...[
          SizedBox(width: 8.w),
          Icon(
            Icons.check_circle_rounded,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
        ],
      ],
    );
  }
}
