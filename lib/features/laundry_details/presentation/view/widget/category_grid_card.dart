import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/count_badge.dart';

/// خانة القسم الرئيسي في الجريد زي الديزاين: الاسم فوق والصورة تحته،
/// والخانات لازقة في بعض وبينها خطوط رفيعة
/// ولو فيه قطع في السلة من القسم ده الخانة بتتلون خفيف ويبان رقم أحمر على الصورة
class CategoryGridCard extends StatelessWidget {
  final ServiceCategoryModel category;

  /// عدد القطع المختارة من القسم، صفر يعني مفيش رقم
  final int selectedPieces;
  final VoidCallback onTap;

  /// آخر خانة في الصف مالهاش خط على جنبها لأن الجريد واصل لحرف الشاشة
  final bool showEndBorder;

  /// آخر صف مالوش خط تحته
  final bool showBottomBorder;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.selectedPieces,
    required this.onTap,
    this.showEndBorder = true,
    this.showBottomBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.borderColor);
    final hasPieces = selectedPieces > 0;

    return Material(
      color: hasPieces
          ? Color.alphaBlend(
              AppColors.primaryColor.withValues(alpha: 0.06),
              AppColors.whiteColor,
            )
          : AppColors.whiteColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              end: showEndBorder ? side : BorderSide.none,
              bottom: showBottomBorder ? side : BorderSide.none,
            ),
          ),
          padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 10.h),
          child: Column(
            children: [
              // مساحة ثابتة لسطرين عشان الصور تفضل على نفس الخط في كل الخانات
              SizedBox(
                height: 13.sp * 1.3 * 2,
                child: Center(
                  child: Text(
                    category.name,
                    style: TextStyles.darkRegular14.copyWith(
                      fontSize: 13.sp,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Expanded(child: _buildImage()),
            ],
          ),
        ),
      ),
    );
  }

  /// الصورة ممكن تكون لينك أو إيموجي جاي من السيرفر، فبنفرق بينهم هنا
  /// والرقم بيتحط في ركن الصورة بـ Stack
  Widget _buildImage() {
    final isEmoji = !category.image.startsWith('http');

    return Stack(
      children: [
        Positioned.fill(
          child: isEmoji
              ? Center(
                  child: Text(
                    category.image.isEmpty ? '🧺' : category.image,
                    style: TextStyle(fontSize: 34.sp),
                  ),
                )
              // contain عشان القطعة تبان كلها على الأبيض زي الديزاين
              : FlexibleImage(
                  source: category.image,
                  borderRadius: 0,
                  fit: BoxFit.contain,
                ),
        ),
        if (selectedPieces > 0)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: CountBadge(count: selectedPieces),
          ),
      ],
    );
  }
}
