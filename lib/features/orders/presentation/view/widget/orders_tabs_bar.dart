import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// تابين جوا بوكس رمادي، المختار بيبقى زرار أزرق والتاني شفاف
/// العدد جنب الاسم بييجي من الشاشة عشان يتحدث لوحده مع الداتا
class OrdersTabsBar extends StatelessWidget {
  final int selectedIndex;
  final int currentCount;
  final int previousCount;
  final ValueChanged<int> onTabSelected;

  const OrdersTabsBar({
    super.key,
    required this.selectedIndex,
    required this.currentCount,
    required this.previousCount,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.semiWhiteColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: '${'orders_current'.tr()} ($currentCount)',
              index: 0,
            ),
          ),
          Expanded(
            child: _buildTab(
              label: '${'orders_previous'.tr()} ($previousCount)',
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({required String label, required int index}) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Text(
          label,
          style: TextStyles.darkBold14.copyWith(
            color: isSelected ? AppColors.whiteColor : AppColors.greyColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
