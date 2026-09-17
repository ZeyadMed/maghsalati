import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/category_grid_card.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// جريد الأقسام الرئيسية، الداتا بتتبعتلها من بره
/// فلما الـ endpoint يتوصل مش هيتغير فيها حاجة
/// والدوس على قسم بيفتح شاشة القطع وهي واقفة على التاب بتاعه
class ServicesSection extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final SelectedServicesController controller;
  final ValueChanged<int> onCategoryTap;

  const ServicesSection({
    super.key,
    required this.categories,
    required this.controller,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // بنسمع على الكنترولر عشان بادج عدد القطع على الكروت تتحدث لوحدها
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryGridCard(
              key: ValueKey(category.id),
              category: category,
              selectedPieces: controller.totalPiecesOf(
                category.items.map((e) => e.id),
              ),
              onTap: () => onCategoryTap(index),
            );
          },
        );
      },
    );
  }
}
