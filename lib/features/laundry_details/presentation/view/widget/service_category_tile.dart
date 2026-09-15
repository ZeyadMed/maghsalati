import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/default_exption_tile.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/pieces_count_badge.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/service_item_tile.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// القسم الرئيسي (ملابس - بدل ...) وجواه القطع الفرعية
/// وبيعرض جنب اسمه عدد القطع المختارة لو فيه اختيارات
class ServiceCategoryTile extends StatelessWidget {
  final ServiceCategoryModel category;
  final SelectedServicesController controller;
  final bool initiallyExpanded;

  const ServiceCategoryTile({
    super.key,
    required this.category,
    required this.controller,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    // بنسمع على الكنترولر عشان البادج والكاونتر يتحدثوا لوحدهم
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final pieces = controller.totalPiecesOf(category.items.map((e) => e.id));

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: DefaultExpansionTile(
            name: category.name,
            image: category.image,
            subtitle: '${category.items.length} ${'available_service'.tr()}',
            lightHeader: true,
            radius: 16.r,
            initiallyExpanded: initiallyExpanded,
            trailing: pieces == 0 ? null : PiecesCountBadge(count: pieces),
            childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 4.h),
            optionsWidget: category.items.map(_buildItem).toList(),
          ),
        );
      },
    );
  }

  Widget _buildItem(ServiceItemModel item) {
    return ServiceItemTile(
      key: ValueKey(item.id),
      item: item,
      quantity: controller.quantityOf(item.id),
      onSelect: () => controller.select(item.id),
      onIncrement: () => controller.increment(item.id),
      onDecrement: () => controller.decrement(item.id),
    );
  }
}
