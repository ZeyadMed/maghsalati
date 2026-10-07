import 'package:easy_localization/easy_localization.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';

/// الجزء الأزرق اللي فوق في شاشة حسابي: العنوان وتحته بيانات المستخدم
/// بياخد نفس شكل هيدر الرئيسية عشان الشاشتين يبقوا متسقين
/// لو [user] لسه null بيعرض لودر، ولو التحميل فشل بيعرض زرار حاول مرة أخرى
class ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final bool hasError;
  final VoidCallback? onRetry;

  const ProfileHeader({
    super.key,
    required this.user,
    this.hasError = false,
    this.onRetry,
  });

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
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 64.r),
            child: _buildState(),
          ),
        ],
      ),
    );
  }

  Widget _buildState() {
    final user = this.user;
    if (user != null) return _buildUserRow(user);
    if (hasError) {
      return Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh_rounded, color: AppColors.whiteColor),
          label: Text(
            'try_again'.tr(),
            style: TextStyles.whiteText(14, weight: FontWeight.w600),
          ),
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.whiteColor),
    );
  }

  /// الأفاتار على جنب والاسم والتليفون والمدينة على الجنب التاني
  Widget _buildUserRow(UserModel user) {
    return Row(
      children: [
        _buildAvatar(user),
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
              // الرقم دايماً بيتعرض من الشمال لليمين
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: _buildSubtitle(user.phoneNumber),
              ),
              if (user.cityName.isNotEmpty) ...[
                SizedBox(height: 2.h),
                _buildSubtitle(user.cityName),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// التليفون والمدينة بنفس الشكل الباهت تحت الاسم
  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: TextStyles.whiteText(
        13,
        weight: FontWeight.w300,
      ).copyWith(color: AppColors.whiteColor.withValues(alpha: 0.85)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// دايرة فيها أول حرف من اسم المستخدم
  Widget _buildAvatar(UserModel user) {
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
      ),
      alignment: Alignment.center,
      child: Text(
        user.initial,
        style: TextStyles.whiteText(26, weight: FontWeight.w700),
      ),
    );
  }
}
