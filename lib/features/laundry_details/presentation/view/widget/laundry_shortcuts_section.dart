import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// الاختصارات اللي تحت الأقسام في تفاصيل المغسلة
/// الترتيب هنا هو ترتيب الصف، فبالعربي أول واحد بيبقى على اليمين زي الديزاين
enum LaundryShortcut {
  groupWashing(Icons.groups_rounded, 'group_washing'),
  priceCenter(Icons.price_change_rounded, 'price_center'),
  serviceArea(Icons.public_rounded, 'service_area'),
  serviceProvider(Icons.storefront_rounded, 'service_provider');

  final IconData icon;

  /// مفتاح الترجمة بتاع الاسم اللي تحت الأيقونة
  final String label;

  const LaundryShortcut(this.icon, this.label);
}

/// شريط أبيض واصل لحرف الشاشة زي شريط الأقسام، فيه 4 أيقونات جوا مربعات
/// بحواف دايرية والاسم تحت كل واحدة
/// الدوس بيرجع الاختصار للشاشة، وهي اللي تقرر تفتح إيه
class LaundryShortcutsSection extends StatelessWidget {
  final ValueChanged<LaundryShortcut> onTap;

  const LaundryShortcutsSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.whiteColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final shortcut in LaundryShortcut.values)
              Expanded(child: _buildItem(shortcut)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(LaundryShortcut shortcut) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => onTap(shortcut),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Column(
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.greyColor5),
              ),
              child: Icon(
                shortcut.icon,
                size: 28.r,
                color: AppColors.greyColor6,
              ),
            ),
            Gap(8.h),
            LocalizedLabel(
              text: shortcut.label,
              style: TextStyles.darkRegular12.copyWith(height: 1.3),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
