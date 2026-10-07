import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/laundry_services_cubit.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/retry_error_view.dart';

/// مركز الأسعار: تاب لكل خدمة رئيسية، وتحته جداول القطع بأسعارها
/// بيجيب الخدمات بنفسه من api/customer/laundries/{laundryId}/services
class PriceCenterScreen extends StatefulWidget {
  final int laundryId;

  const PriceCenterScreen({super.key, required this.laundryId});

  @override
  State<PriceCenterScreen> createState() => _PriceCenterScreenState();
}

class _PriceCenterScreenState extends State<PriceCenterScreen> {
  final LaundryServicesCubit _cubit = getIt<LaundryServicesCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getServices(widget.laundryId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.semiWhiteColor3,
      appBar: CustomAppBar(
        title: 'price_center',
        backgroundColor: AppColors.whiteColor,
      ),
      body: BlocBuilder<LaundryServicesCubit, BaseState<ServiceCategoryModel>>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isInitial || state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          if (state.isFailure) {
            return RetryErrorView(
              message: state.errorMessage,
              onRetry: () => _cubit.getServices(widget.laundryId),
            );
          }

          // الخدمة اللي مالهاش قطع مالهاش أسعار تتعرض فمالهاش تاب
          final categories = state.items
              .where((category) => category.items.isNotEmpty)
              .toList();
          if (categories.isEmpty) {
            return Center(
              child: Text(
                'no_services'.tr(),
                style: TextStyles.greyColor2Regular14,
                textAlign: TextAlign.center,
              ),
            );
          }
          return _buildTabs(categories);
        },
      ),
    );
  }

  /// التابات بتتبني بعد ما الخدمات توصل عشان عددها جاي من السيرفر
  Widget _buildTabs(List<ServiceCategoryModel> categories) {
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          ColoredBox(
            color: AppColors.whiteColor,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.darkTextColor,
              labelStyle: TextStyles.blackBold14,
              unselectedLabelStyle: TextStyles.blackRegular14,
              dividerColor: AppColors.borderColor,
              tabs: [
                for (final category in categories) Tab(text: category.name),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final category in categories) _buildCategory(category),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(ServiceCategoryModel category) {
    final groups = _groupsOf(category);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 24.h),
      itemCount: groups.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) =>
          _buildTable(title: groups[index].$1, items: groups[index].$2),
    );
  }

  /// جدول لكل قسم فرعي فيه قطع، والقطع اللي مش تبع قسم فرعي بتتجمع
  /// في جدول باسم الخدمة نفسها. ولو الـ endpoint مارجعش أقسام فرعية
  /// الخدمة كلها بتبقى جدول واحد
  List<(String, List<ServiceItemModel>)> _groupsOf(
    ServiceCategoryModel category,
  ) {
    final subIds = category.subCategories.map((sub) => sub.id).toSet();
    return [
      for (final sub in category.subCategories)
        (sub.name, category.itemsOf(sub.id)),
      (
        category.name,
        category.items
            .where((item) => !subIds.contains(item.subCategoryId))
            .toList(),
      ),
    ].where((group) => group.$2.isNotEmpty).toList();
  }

  /// زي الديزاين: صف عناوين أزرق فيه اسم القسم والسعر، وتحته صف لكل قطعة
  /// والخانات كلها بينها خطوط رفيعة
  Widget _buildTable({
    required String title,
    required List<ServiceItemModel> items,
  }) {
    final radius = BorderRadius.circular(6.r);
    return ClipRRect(
      borderRadius: radius,
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
        border: TableBorder.all(
          color: AppColors.borderColor,
          borderRadius: radius,
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: AppColors.primaryColor),
            children: [
              _buildCell(title, TextStyles.whiteBold14),
              _buildCell('price'.tr(), TextStyles.whiteBold14),
            ],
          ),
          for (final item in items)
            TableRow(
              decoration: const BoxDecoration(color: AppColors.whiteColor),
              children: [
                _buildCell(item.name, _rowStyle),
                _buildCell(_priceLabel(item.price), _rowStyle),
              ],
            ),
        ],
      ),
    );
  }

  TextStyle get _rowStyle =>
      TextStyles.darkRegular14.copyWith(fontSize: 13.sp, height: 1.3);

  Widget _buildCell(String text, TextStyle style) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }

  String _priceLabel(num price) {
    final value = price % 1 == 0 ? price.toInt().toString() : price.toString();
    return '$value ${'currency'.tr()}';
  }
}
