import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';

/// الجزء اللي فوق في شاشة حسابي على شكل التصميم الصيني: صورة مغسلة باهتة
/// وعليها الأفاتار والاسم والتليفون، وكلمة "تعديل" على الطرف التاني
/// لو [user] لسه null بيعرض لودر، ولو التحميل فشل بيعرض زرار حاول مرة أخرى
class ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final bool hasError;
  final VoidCallback? onRetry;

  /// بيفتح تعديل الملف الشخصي، من الدوسة على السطر كله أو على كلمة تعديل
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.user,
    this.hasError = false,
    this.onRetry,
    this.onEdit,
  });

  static const double _avatarSize = 60;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildBackground()),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 28.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: _avatarSize.r),
            child: _buildState(),
          ),
        ),
      ],
    );
  }

  /// الصورة متغطية بأبيض شبه كامل عشان تبان باهتة زي التصميم،
  /// وآخرها بيدوب في لون الشاشة عشان مايبقاش فيه حد بينها وبين القايمة
  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          Assets.assetsImagesLaundry,
          fit: BoxFit.cover,
          color: AppColors.whiteColor.withValues(alpha: 0.8),
          colorBlendMode: BlendMode.srcOver,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.65, 1],
              colors: [
                AppColors.secondaryColor.withValues(alpha: 0),
                AppColors.secondaryColor.withValues(alpha: 0),
                AppColors.secondaryColor,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildState() {
    final user = this.user;
    if (user != null) return _buildUserRow(user);
    if (hasError) {
      return Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppColors.primaryColor,
          ),
          label: Text(
            'try_again'.tr(),
            style: TextStyles.boldStyle(
              14,
              color: AppColors.primaryColor,
              weight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }

  /// الأفاتار على جنب والاسم والتليفون جنبه، وكلمة تعديل في آخر السطر
  Widget _buildUserRow(UserModel user) {
    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _buildAvatar(user),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: TextStyles.boldStyle(18, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                // الرقم دايماً بيتعرض من الشمال لليمين
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Text(
                    user.phoneNumber,
                    style: TextStyles.boldStyle(
                      13,
                      color: AppColors.greyColor3,
                      weight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'edit'.tr(),
            style: TextStyles.boldStyle(
              15,
              color: AppColors.orangeColor,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// دايرة بيضا بحلقة زرقا رفيعة، وجواها صورة المستخدم
  /// ولو مفيش صورة أو اللينك باظ أول حرف من اسمه على خلفية زرقا
  Widget _buildAvatar(UserModel user) {
    final innerSize = _avatarSize.r - 8.r;
    final initial = Container(
      color: AppColors.primaryColor,
      alignment: Alignment.center,
      child: Text(user.initial, style: TextStyles.whiteText(22)),
    );

    return Container(
      width: _avatarSize.r,
      height: _avatarSize.r,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.primaryColor, width: 1),
      ),
      child: ClipOval(
        child: SizedBox(
          width: innerSize,
          height: innerSize,
          child: user.imageUrl.isEmpty
              ? initial
              : CachedNetworkImage(
                  imageUrl: user.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => initial,
                  errorWidget: (_, _, _) => initial,
                ),
        ),
      ),
    );
  }
}
