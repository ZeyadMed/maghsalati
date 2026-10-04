import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/category_grid_card.dart';

/// جريد الأقسام الرئيسية زي الديزاين: شريط أبيض واصل لحرف الشاشة
/// و4 خانات لازقة في بعض في الصف. الداتا بتتبعتلها من بره
/// فلما الـ endpoint يتوصل مش هيتغير فيها حاجة
/// والدوس على قسم بيفتح شاشة القطع وهي واقفة على التاب بتاعه
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

  /// ارتفاع ثابت للخانة بدل نسبة، عشان لو الأقسام أقل من 4 والخانات عرضت
  /// ماتطولش معاها. واللودينج بيستخدمه عشان يبقى نفس المقاس
  static double get cellHeight => 136.h;

  @override
  Widget build(BuildContext context) {
    // أقل من 4 أقسام بياخدوا العرض كله بدل ما يفضل مكان فاضي في الصف
    final columns = categories.length.clamp(1, maxColumns);
    final rows = (categories.length / columns).ceil();

    // البادج بتعد القطع اللي في سلة السيرفر، فبتتحدث لما السلة تتجاب تاني
    return BlocBuilder<CartCubit, BaseState<CartModel>>(
      bloc: cartCubit,
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        final cart = state.data;
        return ColoredBox(
          color: AppColors.whiteColor,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: cellHeight,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryGridCard(
                key: ValueKey(category.id),
                category: category,
                selectedPieces:
                    cart?.piecesOf(category.items.map((e) => e.id)) ?? 0,
                showEndBorder: index % columns != columns - 1,
                showBottomBorder: index ~/ columns != rows - 1,
                onTap: () => onCategoryTap(index),
              );
            },
          ),
        );
      },
    );
  }
}
