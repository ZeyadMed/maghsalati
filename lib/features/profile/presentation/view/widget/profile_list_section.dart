import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// مقاس الأيقونة والمسافة اللي بعدها، الخط الفاصل بيبدأ من بعدهم تحت الاسم
const double _kIconSize = 21;
const double _kIconGap = 14;
const double _kSidePadding = 16;

/// مجموعة سطور بيضا بعرض الشاشة كلها، بينهم خط رفيع بيبدأ من تحت الاسم
/// زي قوايم شاشة "حسابي" في التصميم الصيني
class ProfileListSection extends StatelessWidget {
  final List<Widget> children;

  const ProfileListSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.whiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const _InsetDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// سطر في القايمة: أيقونة ملونة من غير خلفية، والاسم، والسهم في آخر السطر
class ProfileListRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  /// مفتاح الترجمة بتاع اسم السطر
  final String titleKey;

  /// لون الاسم، والافتراضي الغامق
  final Color? titleColor;
  final VoidCallback? onTap;

  const ProfileListRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.titleKey,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _kSidePadding.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            Icon(icon, size: _kIconSize.r, color: iconColor),
            SizedBox(width: _kIconGap.w),
            Expanded(
              child: Text(
                titleKey.tr(),
                style: TextStyles.boldStyle(
                  14,
                  weight: FontWeight.w500,
                  color: titleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15.r,
              color: AppColors.greyColor5,
            ),
          ],
        ),
      ),
    );
  }
}

/// الخط الفاصل بيبدأ من أول الاسم مش من طرف الشاشة
class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: _kSidePadding.w + _kIconSize.r + _kIconGap.w,
      ),
      child: const Divider(
        height: 1,
        thickness: 0.6,
        color: AppColors.borderColor,
      ),
    );
  }
}
