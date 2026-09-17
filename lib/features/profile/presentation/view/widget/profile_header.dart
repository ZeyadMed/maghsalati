import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';

/// الجزء الأزرق اللي فوق في شاشة حسابي: العنوان وتحته بيانات المستخدم
/// بياخد نفس شكل هيدر الرئيسية عشان الشاشتين يبقوا متسقين
class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        bottom: 24.h,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'profile'.tr(),
            style: TextStyles.whiteText(20, weight: FontWeight.w700),
          ),
          SizedBox(height: 20.h),
          _buildUserRow(),
        ],
      ),
    );
  }

  /// الأفاتار على جنب والاسم والتليفون والإيميل على الجنب التاني
  Widget _buildUserRow() {
    return Row(
      children: [
        _buildAvatar(),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name,
                style: TextStyles.whiteText(18, weight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              _buildSubtitle(user.phone),
              SizedBox(height: 2.h),
              _buildSubtitle(user.email),
            ],
          ),
        ),
      ],
    );
  }

  /// التليفون والإيميل بنفس الشكل الباهت تحت الاسم
  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: TextStyles.whiteText(13, weight: FontWeight.w300).copyWith(
        color: AppColors.whiteColor.withValues(alpha: 0.85),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// صورة المستخدم، ولو مفيش بنعرض أول حرف من اسمه
  Widget _buildAvatar() {
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.whiteColor.withValues(alpha: 0.22),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        image: user.hasImage
            ? DecorationImage(
                image: NetworkImage(user.image!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: user.hasImage
          ? null
          : Text(
              user.initial,
              style: TextStyles.whiteText(26, weight: FontWeight.w700),
            ),
    );
  }
}
