import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/mock/mock_user_data.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_header.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_menu_tile.dart';

/// شاشة حسابي: هيدر أزرق فيه بيانات المستخدم وتحته قايمة الصفحات
/// المستخدم لسه جاي من داتا تجريبية لحد ما ال endpoint يجهز
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _user = MockUserData.user;

  /// بيفتح شاشة تعديل الملف وبيستنى البيانات الجديدة ترجع منها
  /// لو المستخدم حفظ، الهيدر بيتحدث على طول من غير ما نعيد تحميل الشاشة
  Future<void> _openUpdateProfile() async {
    final updated = await context.push<UserModel>(
      AppRouter.updateProfileScreen,
      extra: _user,
    );

    if (updated != null && mounted) {
      setState(() => _user = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Column(
        children: [
          ProfileHeader(user: _user),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._buildMenuTiles(),
                  SizedBox(height: 24.h),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// سطور القايمة، بينهم مسافة ثابتة من غير ما تتحط تحت آخر واحد
  List<Widget> _buildMenuTiles() {
    final tiles = <Widget>[
      ProfileMenuTile(
        icon: Icons.edit_outlined,
        iconColor: AppColors.primaryColor,
        titleKey: 'edit_profile',
        onTap: _openUpdateProfile,
      ),
      ProfileMenuTile(
        icon: Icons.lock_outline_rounded,
        iconColor: AppColors.greenColor,
        titleKey: 'privacy_policy',
        onTap: () => context.push(AppRouter.privacyPolicy),
      ),
      ProfileMenuTile(
        icon: Icons.chat_bubble_outline_rounded,
        iconColor: AppColors.lightBlueColor,
        titleKey: 'contact_us',
        onTap: () => context.push(AppRouter.contactUsScreen),
      ),
      ProfileMenuTile(
        icon: Icons.info_outline_rounded,
        iconColor: AppColors.orangeColor,
        titleKey: 'about_app',
        onTap: () => context.push(AppRouter.aboutUs),
      ),
    ];

    return [
      for (int i = 0; i < tiles.length; i++) ...[
        if (i > 0) SizedBox(height: 12.h),
        tiles[i],
      ],
    ];
  }

  /// زرار تسجيل الخروج، لونه أحمر باهت عشان يبان إنه إجراء مختلف عن باقي القايمة
  Widget _buildLogoutButton() {
    return Material(
      color: AppColors.redColor2.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: _confirmLogout,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 19.r,
                color: AppColors.redColor2,
              ),
              SizedBox(width: 8.w),
              Text(
                'logout'.tr(),
                style: TextStyles.darkBold16.copyWith(
                  color: AppColors.redColor2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بنأكد قبل الخروج عشان مايخرجش بالغلط
  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'logout'.tr(),
          style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'logout_confirm'.tr(),
          style: TextStyles.darkRegular14.copyWith(
            color: AppColors.greyColor2,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(
              'cancel'.tr(),
              style: TextStyles.darkBold14.copyWith(
                color: AppColors.greyColor2,
              ),
            ),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              'logout'.tr(),
              style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      context.go(AppRouter.login);
    }
  }
}
