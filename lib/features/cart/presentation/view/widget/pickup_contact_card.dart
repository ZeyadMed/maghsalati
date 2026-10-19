import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/pickup_contact.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_type_icon.dart';

/// اسم ورقم صاحب الحساب معروضين جاهزين بنفس شكل كارت العنوان،
/// وزرار تعديل لو حد تاني هو اللي هيسلّم الهدوم
class PickupContactCard extends StatelessWidget {
  final PickupContact contact;

  /// الرقم لسه جاي من بيانات الحساب (أول طلب بعد اللوجين)
  final bool loadingPhone;
  final VoidCallback onEdit;

  const PickupContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    this.loadingPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.borderColor),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 4.w, 12.h),
          child: Row(
            children: [
              const AddressTypeIcon(
                icon: Icons.person_outline,
                highlighted: true,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: TextStyles.darkBold14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    _buildPhone(),
                  ],
                ),
              ),
              TextButton(
                onPressed: onEdit,
                child: Text(
                  'edit'.tr(),
                  style: TextStyles.darkBold14.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhone() {
    if (loadingPhone && !contact.hasPhone) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: SizedBox(
          width: 12.r,
          height: 12.r,
          child: const CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }
    // الرقم بكود الدولة فبيتعرض من الشمال لليمين حتى في العربي
    return Text(
      contact.phone,
      textDirection: ui.TextDirection.ltr,
      style: TextStyles.darkRegular12.copyWith(color: AppColors.greyColor2),
      maxLines: 1,
    );
  }
}
