import 'package:flutter/material.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/service_category_tile.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// ليستة الأقسام الرئيسية كلها، الداتا بتتبعتلها من بره
/// فلما الـ endpoint يتوصل مش هيتغير فيها حاجة
class ServicesSection extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final SelectedServicesController controller;

  const ServicesSection({
    super.key,
    required this.categories,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return ServiceCategoryTile(
          key: ValueKey(categories[index].id),
          category: categories[index],
          controller: controller,
          // أول قسم بيبقى مفتوح زي الديزاين
          initiallyExpanded: index == 0,
        );
      },
    );
  }
}
