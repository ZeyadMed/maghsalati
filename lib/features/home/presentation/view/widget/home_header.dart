import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';

class HomeHeader extends StatelessWidget {
  final TextEditingController searchController;

  /// بيمسك العنوان وحالة الصلاحية، والهيدر بيسمع عليه عشان يتحدث لوحده
  final LocationController locationController;
  final String? Function(String?)? onSearchChanged;

  /// بيتبعت من تاب البحث عشان الكيبورد يفتح على الخانة أول ما التاب يتفتح
  final FocusNode? searchFocusNode;

  /// بيتنفذ لما يدوس على العنوان وهو متجاب بالفعل (اختيار موقع تاني بعدين)
  final VoidCallback? onLocationTap;
  final VoidCallback? onLogoTap;

  const HomeHeader({
    super.key,
    required this.searchController,
    required this.locationController,
    this.onSearchChanged,
    this.searchFocusNode,
    this.onLocationTap,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(context),
          SizedBox(height: 18.h),
          _buildSearchField(),
        ],
      ),
    );
  }

  /// اللوجو على الشمال + موقع الاستلام على اليمين
  Widget _buildTopRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Flexible عشان العنوان الطويل ياخد راحته من غير ما يزق اللوجو
        Flexible(child: _buildLocationBlock()),
        // SizedBox(width: 12.w),
        FlexibleImage(
          height: context.screenHeight * 0.05,
          width: context.screenWidth * 0.3,
          source: Assets.assetsImagesLogoLight,
          fit: BoxFit.contain,
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
          onTap: locationController.hasAddress
              ? onLocationTap
              : locationController.retry,
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

    final hasAddress = locationController.hasAddress;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            hasAddress ? locationController.address : 'set_location'.tr(),
            style: TextStyles.whiteText(14, weight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(
          hasAddress ? Icons.keyboard_arrow_down : Icons.refresh,
          size: 16.r,
          color: AppColors.whiteColor,
        ),
      ],
    );
  }

  /// خانة البحث + زرار الموقع
  Widget _buildSearchField() {
    return Customtextfield(
      hintText: 'search_hint',
      textEditingController: searchController,
      focusNode: searchFocusNode,
      onChanged: onSearchChanged,
      borderRadious: 14.r,
      prefix: Padding(
        padding: EdgeInsetsDirectional.only(start: 8.w, end: 4.w),
        child: GestureDetector(
          onTap: onLocationTap,
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
