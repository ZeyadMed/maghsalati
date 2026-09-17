import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/pieces_count_badge.dart';

/// كارت القسم الرئيسي في الجريد: صورة فوق والاسم تحتها
/// ولو فيه قطع مختارة من القسم ده بتبان بادج على الصورة
class CategoryGridCard extends StatelessWidget {
  final ServiceCategoryModel category;

  /// عدد القطع المختارة من القسم، صفر يعني مفيش بادج
  final int selectedPieces;
  final VoidCallback onTap;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.selectedPieces,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selectedPieces > 0
                ? AppColors.primaryColor
                : AppColors.borderColor,
            width: selectedPieces > 0 ? 1.5 : 1,
          ),
        ),
        padding: EdgeInsets.all(8.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _buildImage()),
            SizedBox(height: 8.h),
            Text(
              category.name,
              style: TextStyles.darkBold14.copyWith(fontSize: 13.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// الصورة ممكن تكون لينك أو إيموجي جاي من السيرفر، فبنفرق بينهم هنا
  /// والبادج بتتحط فوقها بـ Stack عشان تبان زي الديزاين
  Widget _buildImage() {
    final isEmoji = !category.image.startsWith('http');

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: isEmoji
                ? Container(
                    color: AppColors.secondaryColor,
                    alignment: Alignment.center,
                    child: Text(
                      category.image,
                      style: TextStyle(fontSize: 32.sp),
                    ),
                  )
                : FlexibleImage(
                    source: category.image,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        if (selectedPieces > 0)
          PositionedDirectional(
            top: 4.h,
            end: 4.w,
            child: PiecesCountBadge(count: selectedPieces),
          ),
      ],
    );
  }
}
