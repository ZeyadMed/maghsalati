import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/saved_address_picker_sheet.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

class HomeHeader extends StatelessWidget {
  /// خانة البحث بتظهر بس لو متبعت (تاب البحث). الصفحة الرئيسية مابتبعتوش،
  /// فبيظهر مكانها زرار "اختر مكانك" في النص
  final TextEditingController? searchController;

  /// بيمسك العنوان وحالة الصلاحية، والهيدر بيسمع عليه عشان يتحدث لوحده
  final LocationController locationController;
  final String? Function(String?)? onSearchChanged;

  /// بيتبعت من تاب البحث عشان الكيبورد يفتح على الخانة أول ما التاب يتفتح
  final FocusNode? searchFocusNode;

  /// بيتنفذ لما يدوس على العنوان، ولو مش متبعت بيفتح شيت العناوين المحفوظة
  final VoidCallback? onLocationTap;
  final VoidCallback? onLogoTap;

  const HomeHeader({
    super.key,
    required this.locationController,
    this.searchController,
    this.onSearchChanged,
    this.searchFocusNode,
    this.onLocationTap,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = this.searchController;
    return Container(
      // بياخد عرض الشاشة كله حتى لو الأب Column بـ crossAxisAlignment.start،
      // وإلا هيدر الرئيسية بيصغر على قد زرار "اختر مكانك" ويسيب فاضي على الشمال
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        bottom: 20.h,
        start: 16.w,
        end: 16.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(28.r),
          bottomEnd: Radius.circular(28.r),
        ),
      ),
      child: searchController == null
          ? _buildLocationHeader(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopRow(context),
                SizedBox(height: 18.h),
                _buildSearchField(context, searchController),
              ],
            ),
    );
  }

  /// الصفحة الرئيسية: اللوجو وتحته زرار "اختر مكانك" في النص
  Widget _buildLocationHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlexibleImage(
          height: context.screenHeight * 0.045,
          width: context.screenWidth * 0.3,
          source: Assets.assetsImagesLogoLight,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 14.h),
        _buildLocationButton(),
      ],
    );
  }

  /// اللوجو على الشمال + موقع الاستلام على اليمين
  Widget _buildTopRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Flexible عشان العنوان الطويل ياخد راحته من غير ما يزق اللوجو
        Flexible(child: _buildLocationBlock()),
        FlexibleImage(
          height: context.screenHeight * 0.05,
          width: context.screenWidth * 0.3,
          source: Assets.assetsImagesLogoLight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  /// شيت العناوين: اختيار عنوان محفوظ بيخليه الافتراضي والمغاسل بتتجاب بيه،
  /// و"موقعي الحالي" بيرجع للـ GPS
  Future<void> _openAddressSwitcher(BuildContext context) async {
    final current = locationController.savedAddress;
    final pick = await SavedAddressPickerSheet.show(
      context,
      selectedId: current?.id,
      showCurrentLocation: true,
      currentLocationSelected: current == null,
      showManageLink: true,
    );
    if (pick == null) return;

    final address = pick.address;
    if (address == null) {
      locationController.useCurrentLocation();
      return;
    }

    // الهيدر والمغاسل بيتحدثوا على طول، والسيرفر بيتبلغ بعدها. ولو فشل
    // الكيوبت بيجيب الليستة تاني والكنترولر بيرجع للافتراضي الحقيقي
    locationController.useSavedAddress(address);
    final error = await getIt<SavedAddressesCubit>().setDefault(address);
    if (error != null && context.mounted) context.showErrorMessage(error);
  }

  /// العنوان الحالي: المحفوظ باسمه الأول (المنزل · العنوان) أو عنوان الـ GPS،
  /// و null لو لسه مفيش عنوان
  InlineSpan? _addressSpan(TextStyle style) {
    final savedAddress = locationController.savedAddress;
    if (savedAddress != null) {
      return TextSpan(
        children: [
          TextSpan(
            text: '${savedAddress.displayTitle} · ',
            style: style.copyWith(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: savedAddress.address),
        ],
      );
    }
    if (locationController.hasAddress) {
      return TextSpan(text: locationController.address);
    }
    return null;
  }

  /// زرار "اختر مكانك" اللي في نص هيدر الصفحة الرئيسية، بيفتح العناوين
  /// المحفوظة. وبيسمع على الكنترولر فالعنوان المختار بيظهر جواه أول ما يوصل
  Widget _buildLocationButton() {
    return AnimatedBuilder(
      animation: locationController,
      builder: (context, _) {
        final radius = BorderRadius.circular(30.r);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.screenWidth * 0.86),
          child: Material(
            color: AppColors.whiteColor,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              // حتى لو الموقع ماتجابش، الشيت فيه "موقعي الحالي" (بيحاول تاني
              // أو يفتح الإعدادات) والعناوين المحفوظة وإضافة عنوان من الخريطة
              onTap: onLocationTap ?? () => _openAddressSwitcher(context),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 8.w,
                  end: 12.w,
                  top: 6.h,
                  bottom: 6.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.redColor2.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        size: 18.r,
                        color: AppColors.redColor2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(child: _buildButtonLabel()),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.r,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// "اختر مكانك" وتحتها العنوان المختار، أو "اختر مكانك" لوحدها لو مفيش عنوان
  Widget _buildButtonLabel() {
    final titleStyle = TextStyles.whiteText(
      14,
      weight: FontWeight.w700,
    ).copyWith(color: AppColors.darkTextColor);

    if (locationController.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.r,
            height: 12.r,
            child: const CircularProgressIndicator(
              strokeWidth: 1.6,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(width: 8.w),
          Text('locating'.tr(), style: titleStyle),
        ],
      );
    }

    final address = _addressSpan(titleStyle);
    if (address == null) {
      return Text('choose_location'.tr(), style: titleStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'choose_location'.tr(),
          style: TextStyles.whiteText(
            11,
            weight: FontWeight.w400,
          ).copyWith(color: AppColors.lightTextColor, height: 1.2),
        ),
        Text.rich(
          address,
          style: titleStyle.copyWith(height: 1.3),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// "موقع الاستلام" وتحتها العنوان الحالي مع سهم
  /// بيسمع على الكنترولر فالعنوان بيتحدث لوحده أول ما يوصل
  Widget _buildLocationBlock() {
    return AnimatedBuilder(
      animation: locationController,
      builder: (context, _) {
        return GestureDetector(
          // حتى لو الموقع ماتجابش، الشيت فيه "موقعي الحالي" (بيحاول تاني
          // أو يفتح الإعدادات) والعناوين المحفوظة وإضافة عنوان من الخريطة
          onTap: onLocationTap ?? () => _openAddressSwitcher(context),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'pickup_location'.tr(),
                style: TextStyles.whiteText(
                  11,
                  weight: FontWeight.w300,
                ).copyWith(color: AppColors.whiteColor.withValues(alpha: 0.8)),
              ),
              SizedBox(height: 2.h),
              _buildAddressRow(),
            ],
          ),
        );
      },
    );
  }

  /// العنوان نفسه: لودر وهو بيجيب، والعنوان أو "حدد موقعك" بعد كده
  Widget _buildAddressRow() {
    if (locationController.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.r,
            height: 12.r,
            child: CircularProgressIndicator(
              strokeWidth: 1.6,
              color: AppColors.whiteColor,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'locating'.tr(),
            style: TextStyles.whiteText(13, weight: FontWeight.w500),
          ),
        ],
      );
    }

    final style = TextStyles.whiteText(14, weight: FontWeight.w600);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text.rich(
            _addressSpan(style) ?? TextSpan(text: 'set_location'.tr()),
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(
          Icons.keyboard_arrow_down,
          size: 16.r,
          color: AppColors.whiteColor,
        ),
      ],
    );
  }

  /// خانة البحث + زرار الموقع
  Widget _buildSearchField(
    BuildContext context,
    TextEditingController searchController,
  ) {
    return Customtextfield(
      hintText: 'search_hint',
      textEditingController: searchController,
      focusNode: searchFocusNode,
      onChanged: onSearchChanged,
      borderRadious: 14.r,
      prefix: Padding(
        padding: EdgeInsetsDirectional.only(start: 8.w, end: 4.w),
        child: GestureDetector(
          onTap: onLocationTap ?? () => _openAddressSwitcher(context),
          child: SizedBox(
            width: 36.r,
            height: 36.r,
            child: Icon(
              Icons.location_on,
              size: 20.r,
              color: AppColors.redColor2,
            ),
          ),
        ),
      ),
    );
  }
}
