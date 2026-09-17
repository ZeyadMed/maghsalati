import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_sub_category_model.dart';

/// شيبس الأقسام الفرعية اللي بتفلتر القطع (الكل - قمصان - بناطيل ...)
/// "الكل" بيتحط أول واحد وقيمته null يعني من غير فلترة
class SubCategoryFilterChips extends StatelessWidget {
  final List<ServiceSubCategoryModel> subCategories;

  /// الـ id المختار حالياً، و null يعني "الكل"
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const SubCategoryFilterChips({
    super.key,
    required this.subCategories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (subCategories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        // +1 عشان شيب "الكل" اللي في الأول
        itemCount: subCategories.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip(label: 'all'.tr(), id: null);
          }
          final sub = subCategories[index - 1];
          return _buildChip(label: sub.name, id: sub.id);
        },
      ),
    );
  }

  Widget _buildChip({required String label, required int? id}) {
    final isSelected = selectedId == id;

    return InkWell(
      onTap: () => onSelected(id),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? TextStyles.whiteText(12, weight: FontWeight.w500)
              : TextStyles.darkRegular12,
        ),
      ),
    );
  }
}
