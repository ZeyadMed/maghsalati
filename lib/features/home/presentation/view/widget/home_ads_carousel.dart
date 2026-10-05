import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/widget/carousel_slider_widget.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/core/widget/loading_shimmer.dart';
import 'package:maghsalati/features/home/data/model/advertisement_model.dart';
import 'package:maghsalati/features/home/presentation/view_model/advertisements_cubit.dart';

/// بانرات الهوم جاية من api/auth/advertisements وبنعرض الصورة بس
/// والبانر مش أساسي، فلو الطلب فشل أو رجع فاضي بيختفي ومعاه المسافة اللي تحته
class HomeAdsCarousel extends StatelessWidget {
  const HomeAdsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdvertisementsCubit>()..getAdvertisements(),
      child: BlocBuilder<AdvertisementsCubit, BaseState<AdvertisementModel>>(
        builder: (context, state) {
          final height = context.screenHeight * 0.2;

          if (state.isInitial || state.isLoading) {
            return _withBottomGap(
              ShimmerBox(height: height, width: double.infinity),
            );
          }
          if (state.isFailure || state.items.isEmpty) {
            return const SizedBox.shrink();
          }

          return _withBottomGap(
            CarouselSliderWidget(
              // إعلان واحد مالوش لازمة يلف
              autoPlay: state.items.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              height: height,
              widgets: [
                for (final ad in state.items)
                  FlexibleImage(
                    source: ad.imageUrl,
                    width: double.infinity,
                    height: height,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _withBottomGap(Widget child) {
    return Padding(padding: EdgeInsets.only(bottom: 16.h), child: child);
  }
}
