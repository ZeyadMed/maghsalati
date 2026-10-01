import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/category_grid_card.dart';

/// جريد الأقسام الرئيسية، الداتا بتتبعتلها من بره
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

  @override
  Widget build(BuildContext context) {
    // البادج بتعد القطع اللي في سلة السيرفر مش اللي في الكاونتر،
    // فمابتتغيرش مع + و - وبتتحدث بس لما "أضف للسلة" ينجح
    return BlocBuilder<CartCubit, BaseState<CartModel>>(
      bloc: cartCubit,
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        final cart = state.data;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryGridCard(
              key: ValueKey(category.id),
              category: category,
              selectedPieces:
                  cart?.piecesOf(category.items.map((e) => e.id)) ?? 0,
              onTap: () => onCategoryTap(index),
            );
          },
        );
      },
    );
  }
}
