import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';

/// أيقونة العنوان جوه مربع ملون: بيت للمنزل، شنطة للعمل، ودبوس لأي اسم تاني
class AddressTypeIcon extends StatelessWidget {
  final SavedAddressModel? address;

  /// بتتبعت بدل [address] لما الأيقونة مش لعنوان محفوظ (زي موقعي الحالي)
  final IconData? icon;
  final bool highlighted;

  const AddressTypeIcon({
    super.key,
    this.address,
    this.icon,
    this.highlighted = false,
  });

  IconData get _icon {
    if (icon != null) return icon!;
    if (address?.isHome ?? false) return Icons.home_outlined;
    if (address?.isWork ?? false) return Icons.work_outline_rounded;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.primaryColor : AppColors.greyColor3;
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11.r),
      ),
      alignment: Alignment.center,
      child: Icon(_icon, size: 21.r, color: color),
    );
  }
}
