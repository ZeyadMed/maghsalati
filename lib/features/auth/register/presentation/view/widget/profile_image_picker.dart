import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/helpers/image_picker_helper.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// دايرة صورة البروفايل في التسجيل وتعديل الملف
/// الضغط عليها بيفتح شيت الكاميرا/المعرض، والصورة المختارة بتتعرض مكان الأيقونة
/// ولو مفيش صورة مختارة بتتعرض [imageUrl] الحالية لو موجودة
class ProfileImagePicker extends StatelessWidget {
  final File? image;
  final String imageUrl;
  final ValueChanged<File?> onImagePicked;

  const ProfileImagePicker({
    super.key,
    required this.image,
    required this.onImagePicked,
    this.imageUrl = '',
  });

  ImageProvider? get _preview {
    final image = this.image;
    if (image != null) return FileImage(image);
    if (imageUrl.isNotEmpty) return CachedNetworkImageProvider(imageUrl);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return GestureDetector(
      onTap: () => ImagePickerHelper.showImagePicker(context, onImagePicked),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: AppColors.whiteColor,
                backgroundImage: preview,
                // لو اللينك باظ بنسيب الدايرة فاضية بدل ما نرمي exception
                onBackgroundImageError: preview != null ? (_, _) {} : null,
                child: preview == null
                    ? Icon(
                        Icons.person_outline,
                        size: 48.sp,
                        color: AppColors.greyColor4,
                      )
                    : null,
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.whiteColor, width: 2),
                  ),
                  child: Icon(
                    preview == null ? Icons.camera_alt : Icons.edit,
                    size: 16.sp,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
          Gap(8.h),
          Text(
            preview == null
                ? 'add_profile_image'.tr()
                : 'change_profile_image'.tr(),
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
