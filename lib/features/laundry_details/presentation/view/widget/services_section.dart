import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/category_grid_card.dart';

/// أقسام المغسلة زي الديزاين: أول 4 في شريط أبيض واصل لحرف الشاشة،
/// الاسم فوق والصورة تحته والخانات لازقة في بعض
/// والباقي في شريط تاني تحته، كل خانة نص الشاشة والصورة جنب الاسم،
/// ولو أكتر من 2 الشريط بيتسحب بالعرض
/// الداتا بتتبعتلها من بره، والدوس على قسم بيفتح شاشة القطع وهي واقفة على التاب بتاعه
class ServicesSection extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final CartCubit cartCubit;
  final ValueChanged<int> onCategoryTap;

  const ServicesSection({
    super.key,
    required this.categories,
    required this.cartCubit,
    required this.onCategoryTap,
  });

  static const int maxColumns = 4;

  /// خانات الشريط التاني اللي بتبان في عرض الشاشة
  static const int _moreColumns = 2;

  /// ارتفاع ثابت للخانة بدل نسبة، عشان لو الأقسام أقل من 4 والخانات عرضت
  /// ماتطولش معاها. واللودينج بيستخدمه عشان يبقى نفس المقاس
  static double get cellHeight => 136.h;

  @override
  Widget build(BuildContext context) {
    final topCategories = categories.take(maxColumns).toList();
    final moreCategories = categories.skip(maxColumns).toList();

    // البادج بتعد القطع اللي في سلة السيرفر، فبتتحدث لما السلة تتجاب تاني
    return BlocBuilder<CartCubit, BaseState<CartModel>>(
      bloc: cartCubit,
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        final cart = state.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopStrip(topCategories, cart),
            if (moreCategories.isNotEmpty) ...[
              Gap(12.h),
              _buildMoreStrip(moreCategories, cart),
            ],
          ],
        );
      },
    );
  }

  /// أقل من 4 أقسام بياخدوا العرض كله بدل ما يفضل مكان فاضي في الصف
  Widget _buildTopStrip(List<ServiceCategoryModel> items, CartModel? cart) {
    return _buildStrip(
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: _buildCard(
                category: items[i],
                cart: cart,
                index: i,
                showEndBorder: i != items.length - 1,
              ),
            ),
        ],
      ),
    );
  }

  /// قسم واحد بياخد العرض كله، واتنين كل واحد نص. ولو أكتر الخانة بتصغر
  /// شوية عشان طرف التالتة يبان واليوزر يعرف إن الشريط بيتسحب
  Widget _buildMoreStrip(List<ServiceCategoryModel> items, CartModel? cart) {
    final visibleColumns = items.length > _moreColumns
        ? _moreColumns + 0.25
        : items.length;

    return _buildStrip(
      child: LayoutBuilder(
        builder: (context, constraints) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemExtent: constraints.maxWidth / visibleColumns,
          itemBuilder: (context, i) => _buildCard(
            category: items[i],
            cart: cart,
            // الرقم في ليستة الأقسام كلها عشان شاشة القطع تقف على التاب الصح
            index: maxColumns + i,
            showEndBorder: i != items.length - 1,
            horizontalLayout: true,
          ),
        ),
      ),
    );
  }

  Widget _buildStrip({required Widget child}) {
    return ColoredBox(
      color: AppColors.whiteColor,
      child: SizedBox(height: cellHeight, child: child),
    );
  }

  Widget _buildCard({
    required ServiceCategoryModel category,
    required CartModel? cart,
    required int index,
    required bool showEndBorder,
    bool horizontalLayout = false,
  }) {
    return CategoryGridCard(
      key: ValueKey(category.id),
      category: category,
      selectedPieces: cart?.piecesOf(category.items.map((e) => e.id)) ?? 0,
      showEndBorder: showEndBorder,
      horizontalLayout: horizontalLayout,
      onTap: () => onCategoryTap(index),
    );
  }
}
