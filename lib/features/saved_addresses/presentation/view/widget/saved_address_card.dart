import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_type_icon.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/default_address_badge.dart';

enum _AddressAction { setDefault, edit, delete }

/// كارت عنوان في شاشة عناويني: الاسم والعنوان والتفاصيل، ومنيو فيها
/// تعيين كافتراضي والتعديل والحذف. الدوس على الكارت نفسه بيفتح التعديل
class SavedAddressCard extends StatelessWidget {
  final SavedAddressModel address;

  /// فيه عملية شغالة على العنوان ده، فبيظهر لودر مكان المنيو
  final bool isBusy;

  /// فيه عملية شغالة على عنوان تاني، فالمنيو بتتقفل لحد ما تخلص
  final bool isDisabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const SavedAddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.isBusy = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        // الافتراضي متحدد بلون البراند عشان يبان من أول نظرة
        side: BorderSide(
          color: address.isDefault
              ? AppColors.primaryColor.withValues(alpha: 0.5)
              : AppColors.borderColor,
        ),
      ),
      child: InkWell(
        onTap: isDisabled || isBusy ? null : onEdit,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 4.w, 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddressTypeIcon(address: address, highlighted: address.isDefault),
              SizedBox(width: 12.w),
              Expanded(child: _buildInfo()),
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                address.displayTitle,
                style: TextStyles.darkBold14.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (address.isDefault) ...[
              SizedBox(width: 8.w),
              const DefaultAddressBadge(),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          address.address,
          style: TextStyles.darkRegular12.copyWith(
            color: AppColors.greyColor2,
            height: 1.5,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (address.hasDetails) ...[
          SizedBox(height: 4.h),
          Text(
            address.additionalDetails!.trim(),
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.greyColor3,
              fontSize: 11.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing() {
    if (isBusy) {
      return Padding(
        padding: EdgeInsets.all(12.r),
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    return PopupMenuButton<_AddressAction>(
      enabled: !isDisabled,
      color: AppColors.whiteColor,
      icon: Icon(Icons.more_vert, size: 20.r, color: AppColors.greyColor3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (action) => switch (action) {
        _AddressAction.setDefault => onSetDefault(),
        _AddressAction.edit => onEdit(),
        _AddressAction.delete => onDelete(),
      },
      itemBuilder: (context) => [
        // الافتراضي مابيتلغيش من هنا، بيتغير لما عنوان تاني يتعمل افتراضي
        if (!address.isDefault)
          _buildMenuItem(
            _AddressAction.setDefault,
            Icons.check_circle_outline,
            'set_as_default',
            AppColors.greenColor,
          ),
        _buildMenuItem(
          _AddressAction.edit,
          Icons.edit_outlined,
          'edit',
          AppColors.primaryColor,
        ),
        _buildMenuItem(
          _AddressAction.delete,
          Icons.delete_outline_rounded,
          'delete',
          AppColors.redColor2,
        ),
      ],
    );
  }

  PopupMenuItem<_AddressAction> _buildMenuItem(
    _AddressAction action,
    IconData icon,
    String titleKey,
    Color color,
  ) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 19.r, color: color),
          SizedBox(width: 10.w),
          Text(
            titleKey.tr(),
            style: TextStyles.darkRegular14.copyWith(
              color: action == _AddressAction.delete ? color : null,
            ),
          ),
        ],
      ),
    );
  }
}
