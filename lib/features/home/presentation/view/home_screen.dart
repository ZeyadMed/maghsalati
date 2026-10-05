import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/home/presentation/view/widget/home_ads_carousel.dart';
import 'package:maghsalati/features/home/presentation/view/widget/home_header.dart';
import 'package:maghsalati/features/home/presentation/view/widget/nearby_laundries_list.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/home/presentation/view_model/nearby_laundries_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// جاي من get_it فالعنوان متشارك مع باقي الشاشات ومابيتجابش كل مرة
  final LocationController _locationController = getIt<LocationController>();

  /// بيجيب المغاسل القريبة، والبحث اللي في الهيدر بيبعت عليه نفس الطلب بـ search
  late final NearbyLaundriesCubit _laundriesCubit =
      getIt<NearbyLaundriesCubit>()..start();

  @override
  void initState() {
    super.initState();
    // بيطلب الصلاحية ويجيب العنوان أول ما الشاشة تفتح
    // و load بتشتغل مرة واحدة بس حتى لو الشاشة اتبنت تاني
    // والـ cubit بيستنى الموقع ده ويجيب بيه المغاسل القريبة
    _locationController.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _laundriesCubit.close();
    // الكنترولر مش بيتعمله dispose هنا لأنه singleton في get_it
    // وشاشات تانية لسه محتاجاه
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _laundriesCubit,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.semiWhiteColor3,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            searchController: _searchController,
            locationController: _locationController,
            onSearchChanged: (value) {
              _laundriesCubit.search(value ?? '');
              return null;
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(16.h),
                    // المسافة اللي تحته جواه عشان تختفي معاه لو مفيش إعلانات
                    const HomeAdsCarousel(),
                    LocalizedLabel(
                      text: 'cleaner_near_you',
                      style: TextStyles.blackBold16.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Gap(12.h),
                    const NearbyLaundriesList(),
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
