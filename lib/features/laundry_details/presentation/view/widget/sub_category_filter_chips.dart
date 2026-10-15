import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// شيبس الفروع اللي تحت البانر (قمصان - بناطيل ...) وكل شيب بيعرض أنواعه
/// في الجريد. زي الديزاين مفيش "الكل"، فلازم شيب يكون مختار دايماً
class SubCategoryFilterChips extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const SubCategoryFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: labels.length,
        separatorBuilder: (context, index) => SizedBox(width: 14.w),
        itemBuilder: (context, index) => _buildChip(labels[index], index),
      ),
    );
  }

  /// كلهم بعرض واحد تقريباً زي الديزاين، والاسم الطويل بيوسّع الشيب بتاعه
  Widget _buildChip(String label, int index) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onSelected(index),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        constraints: BoxConstraints(minWidth: 76.w),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.greyColor5,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? TextStyles.whiteText(14, weight: FontWeight.w500)
              : TextStyles.darkRegular14,
          maxLines: 1,
        ),
      ),
    );
  }
}
