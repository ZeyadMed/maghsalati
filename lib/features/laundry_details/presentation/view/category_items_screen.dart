import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/cart_bottom_sheet.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/cart_floating_button.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/service_item_card.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/services_promo_banner.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/sub_category_filter_chips.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

/// شاشة القطع: تابات لكل الأقسام الرئيسية فوق، وتحتها شيبس الأقسام الفرعية
/// والقطع في جريد. الكنترولر بيتبعت من شاشة التفاصيل فالسلة مشتركة بين الشاشتين
class CategoryItemsScreen extends StatefulWidget {
  final List<ServiceCategoryModel> categories;
  final SelectedServicesController controller;

  /// القسم اللي الشاشة بتفتح عليه، جاي من الكارت اللي اتداس عليه
  final int initialIndex;

  /// اسم المغسلة بيتعرض في الأبار
  final String title;

  /// بيتنفذ لما يدوس على إتمام الطلب من جوا شيت السلة
  final VoidCallback? onConfirmOrder;

  const CategoryItemsScreen({
    super.key,
    required this.categories,
    required this.controller,
    required this.title,
    this.initialIndex = 0,
    this.onConfirmOrder,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// الفلتر المختار لكل قسم (categoryId -> subCategoryId)
  /// محفوظ لكل قسم لوحده عشان لما ترجع للتاب تلاقي فلترك زي ما سيبته
  final Map<int, int?> _selectedSubCategories = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.categories.length,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, widget.categories.length - 1),
    );
    // الشيبس بتتغير مع التاب فمحتاجين rebuild مع كل تنقل
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  ServiceCategoryModel get _currentCategory =>
      widget.categories[_tabController.index];

  /// بيفتح شيت السلة، وإتمام الطلب من جواه بيرجع لشاشة التفاصيل عشان
  /// هي اللي بتبني الطلب وتبعته
  void _openCart() {
    CartBottomSheet.show(
      context: context,
      controller: widget.controller,
      categories: widget.categories,
      onConfirm: widget.onConfirmOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = _currentCategory;
    final selectedSub = _selectedSubCategories[category.id];
    final items = category.itemsOf(selectedSub);

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: _buildAppBar(),
      floatingActionButton: CartFloatingButton(
        controller: widget.controller,
        onTap: _openCart,
      ),
      body: Column(
        children: [
          ServicesPromoBanner(title: 'promo_banner_title'.tr()),
          Gap(12.h),
          SubCategoryFilterChips(
            subCategories: category.subCategories,
            selectedId: selectedSub,
            onSelected: (id) => setState(() {
              _selectedSubCategories[category.id] = id;
            }),
          ),
          if (category.subCategories.isNotEmpty) Gap(12.h),
          Expanded(child: _buildItemsGrid(items)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      centerTitle: true,
      title: Text(widget.title, style: TextStyles.darkBold18),
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.darkTextColor,
          // بيتقلب تلقائي في العربي فيبقى ناحية اليمين
          textDirection: Directionality.of(context),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(46.h),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.greyColor3,
          labelStyle: TextStyles.blackBold14,
          unselectedLabelStyle: TextStyles.blackRegular14,
          dividerColor: AppColors.borderColor,
          tabs: widget.categories
              .map((category) => Tab(text: category.name))
              .toList(),
        ),
      ),
    );
  }

  /// الجريد بيسمع على الكنترولر عشان الكاونتر يتحدث مع كل زيادة أو نقصان
  Widget _buildItemsGrid(List<ServiceItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('no_items'.tr(), style: TextStyles.greyColor2Regular14),
      );
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 90.h),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.66,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return ServiceItemCard(
              key: ValueKey(item.id),
              item: item,
              quantity: widget.controller.quantityOf(item.id),
              onSelect: () => widget.controller.select(item.id),
              onIncrement: () => widget.controller.increment(item.id),
              onDecrement: () => widget.controller.decrement(item.id),
            );
          },
        );
      },
    );
  }
}
