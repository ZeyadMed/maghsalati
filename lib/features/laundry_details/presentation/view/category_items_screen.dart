import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/cart_bottom_bar.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/cart_bottom_sheet.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/service_item_card.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/services_promo_banner.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/sub_category_filter_chips.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/add_to_cart_cubit.dart';

/// شاشة القطع: تابات لكل الأقسام الرئيسية فوق، وتحتها شيبس الأقسام الفرعية
/// والقطع في جريد 3 في الصف. الدوسة على القطعة بتزود منها واحدة في سلة السيرفر،
/// والسلة اللي تحت بتفتح الشيت اللي فيه تعديل الكميات والمسح
class CategoryItemsScreen extends StatefulWidget {
  final List<ServiceCategoryModel> categories;

  /// القسم اللي الشاشة بتفتح عليه، جاي من الكارت اللي اتداس عليه
  final int initialIndex;

  /// اسم المغسلة بيتعرض في الأبار
  final String title;

  /// بيتنفذ لما يدوس على تأكيد الطلب من البار أو من جوا شيت السلة
  final ValueChanged<CartModel>? onConfirmOrder;

  const CategoryItemsScreen({
    super.key,
    required this.categories,
    required this.title,
    this.initialIndex = 0,
    this.onConfirmOrder,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen>
    with SingleTickerProviderStateMixin {
  static const int _columns = 3;

  late final TabController _tabController;

  /// الفلتر المختار لكل قسم (categoryId -> subCategoryId)
  /// محفوظ لكل قسم لوحده عشان لما ترجع للتاب تلاقي فلترك زي ما سيبته
  final Map<int, int?> _selectedSubCategories = {};

  /// كل دوسة على قطعة بتزود منها واحدة في سلة العميل
  final AddToCartCubit _addToCartCubit = getIt<AddToCartCubit>();

  /// singleton ومشترك مع تاب السلة، فمش بيتعمله close هنا
  final CartCubit _cartCubit = getIt<CartCubit>();

  /// سعر كل قطعة (itemId -> السعر) عشان السعر التقديري يزيد مع الدوسة
  /// قبل ما السلة الجديدة توصل من السيرفر
  late final Map<int, num> _prices = {
    for (final category in widget.categories)
      for (final ServiceItemModel item in category.items) item.id: item.price,
  };

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
    // الأرقام اللي على القطع والسلة جاية من سلة السيرفر، فلو لسه ماتجابتش بنجيبها
    if (_cartCubit.state.data == null) _cartCubit.getCart();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _addToCartCubit.close();
    super.dispose();
  }

  ServiceCategoryModel get _currentCategory =>
      widget.categories[_tabController.index];

  /// بيفتح شيت السلة، وإتمام الطلب من جواه بيرجع لشاشة التفاصيل عشان
  /// هي اللي بتبني الطلب وتبعته
  void _openCart() {
    CartBottomSheet.show(context: context, onConfirm: widget.onConfirmOrder);
  }

  @override
  Widget build(BuildContext context) {
    final category = _currentCategory;
    final selectedSub = _selectedSubCategories[category.id];
    final items = category.itemsOf(selectedSub);

    return BlocListener<AddToCartCubit, BaseState<Map<int, int>>>(
      bloc: _addToCartCubit,
      listenWhen: (previous, current) =>
          previous.status != current.status && current.isFailure,
      listener: (context, state) =>
          context.showErrorMessage(state.errorMessage ?? 'try_again'.tr()),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: _buildAppBar(),
        bottomNavigationBar: _withCart(_buildBottomBar),
        body: Column(
          children: [
            // ServicesPromoBanner(title: 'promo_banner_title'.tr()),
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

  /// الرقم على القطع والسلة اللي تحت = سلة السيرفر + الدوسات اللي لسه بتتبعت
  /// فبيسمع على الاتنين
  Widget _withCart(
    Widget Function(CartModel? cart, Map<int, int> pending) builder,
  ) {
    return BlocBuilder<CartCubit, BaseState<CartModel>>(
      bloc: _cartCubit,
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, cartState) =>
          BlocBuilder<AddToCartCubit, BaseState<Map<int, int>>>(
            bloc: _addToCartCubit,
            builder: (context, addState) =>
                builder(cartState.data, addState.data ?? const {}),
          ),
    );
  }

  /// خانات لازقة في بعض من غير مسافات، وخط فوق أول صف
  /// والباقي كل خانة بترسم الخط اللي تحتها واللي على جنبها
  Widget _buildItemsGrid(List<ServiceItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('no_items'.tr(), style: TextStyles.greyColor2Regular14),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: _withCart(
        (cart, pending) => GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return ServiceItemCard(
              key: ValueKey(item.id),
              item: item,
              quantity:
                  (cart?.piecesOf([item.id]) ?? 0) + (pending[item.id] ?? 0),
              showEndBorder: index % _columns != _columns - 1,
              onTap: () => _addToCartCubit.addOne(item.id),
            );
          },
        ),
      ),
    );
  }

  /// السعر التقديري = إجمالي سلة السيرفر + أسعار الدوسات اللي لسه بتتبعت
  /// والتأكيد والشيت بيستنوا لحد ما الدوسات توصل عشان السلة تبقى آخر حاجة
  Widget _buildBottomBar(CartModel? cart, Map<int, int> pending) {
    final pendingPieces = pending.values.fold(0, (sum, count) => sum + count);
    final pendingPrice = pending.entries.fold<num>(
      0,
      (sum, entry) => sum + (_prices[entry.key] ?? 0) * entry.value,
    );
    final isSyncing = _addToCartCubit.isSyncing;
    final onConfirm = widget.onConfirmOrder;

    return CartBottomBar(
      pieces: (cart?.totalPieces ?? 0) + pendingPieces,
      estimatedPrice: (cart?.itemsTotal ?? 0) + pendingPrice,
      deliveryFees: cart?.deliveryFees ?? 0,
      isBusy: isSyncing,
      onBasketTap: isSyncing ? null : _openCart,
      onConfirm: cart == null || onConfirm == null
          ? null
          : () => onConfirm(cart),
    );
  }
}
