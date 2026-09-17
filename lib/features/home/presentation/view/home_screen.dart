import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/carousel_slider_widget.dart';
import 'package:maghsalati/features/home/presentation/view/widget/cleaner_item.dart';
import 'package:maghsalati/features/home/presentation/view/widget/home_header.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// جاي من get_it فالعنوان متشارك مع باقي الشاشات ومابيتجابش كل مرة
  final LocationController _locationController = getIt<LocationController>();

  @override
  void initState() {
    super.initState();
    // بيطلب الصلاحية ويجيب العنوان أول ما الشاشة تفتح
    // و load بتشتغل مرة واحدة بس حتى لو الشاشة اتبنت تاني
    _locationController.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // الكنترولر مش بيتعمله dispose هنا لأنه singleton في get_it
    // وشاشات تانية لسه محتاجاه
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.semiWhiteColor3,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            searchController: _searchController,
            locationController: _locationController,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(16.h),
                    CarouselSliderWidget(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      height: context.screenHeight * 0.2,
                      widgets: [
                        Image.asset(
                          Assets.assetsImagesLaundry,
                          fit: BoxFit.cover,
                        ),
                        Image.asset(
                          Assets.assetsImagesLaundry,
                          fit: BoxFit.cover,
                        ),
                        Image.asset(
                          Assets.assetsImagesLaundry,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    Gap(16.h),
                    LocalizedLabel(
                      text: 'cleaner_near_you',
                      style: TextStyles.blackBold16.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Gap(12.h),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: CleanerItem(
                          onTap: () => context.push(AppRouter.laundryDetails),
                          image: Assets.assetsImagesCleaner,
                          name: 'John Doe',
                          distance: 2.5,
                          isAvailable: true,
                          rating: 4.5,
                          ratingCount: 120,
                          pickUpTime: 'اليوم',
                          deliveryTime: 'غدا',
                          services: ['Laundry', 'Dry Cleaning'],
                          deliveryPrice: 5.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
