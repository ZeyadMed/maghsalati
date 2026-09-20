import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/home/presentation/view/home_screen.dart';
import 'package:maghsalati/features/home/presentation/view/widget/cleaner_item.dart';
import 'package:maghsalati/features/home/presentation/view/widget/home_header.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';

/// تاب البحث: نفس ديزاين الهوم بالظبط، بس الكيبورد بيفتح على خانة البحث
/// أول ما التاب يتفتح، والسلايدر بيختفي وهو بيكتب عشان النتايج تاخد الشاشة
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

/// public عشان البوتوم ناف يقدر ينادي focusSearch أول ما التاب يتفتح
class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// عشان نفتح الكيبورد على الخانة أول ما التاب يتفتح
  final FocusNode _searchFocusNode = FocusNode();

  /// نفس اللوكيشن المتشارك بتاع الهوم، جاي من get_it
  final LocationController _locationController = getIt<LocationController>();

  /// النص اللي بيتكتب دلوقتي، بيتفلتر بيه اللستة
  String _query = '';

  @override
  void initState() {
    super.initState();
    _locationController.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    // الكنترولر مش بيتعمله dispose هنا لأنه singleton في get_it
    super.dispose();
  }

  /// بيتنادى من البوتوم ناف أول ما التاب ده يتفتح عشان الكيبورد يطلع
  void focusSearch() {
    if (mounted) _searchFocusNode.requestFocus();
  }

  void _onSearchChanged(String? value) {
    setState(() => _query = (value ?? '').trim());
  }

  /// TODO: استبدل الفلترة دي بنتايج البحث من ال endpoint لما يجهز
  List<String> get _results {
    const names = [
      'مغسلة النخبة',
      'مغسلة الصفاء',
      'مغسلة النور',
      'مغسلة الياسمين',
      'مغسلة الأمانة',
      'مغسلة الجودة',
    ];

    if (_query.isEmpty) return names;
    return names.where((name) => name.contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _query.isNotEmpty;
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.semiWhiteColor3,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            searchController: _searchController,
            locationController: _locationController,
            searchFocusNode: _searchFocusNode,
            onSearchChanged: (value) {
              _onSearchChanged(value);
              return null;
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: results.isEmpty
                  ? _buildNoResults()
                  : _buildResults(isSearching, results),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64.r, color: AppColors.greyColor5),
          Gap(12.h),
          LocalizedLabel(text: 'no_search_results', style: TextStyles.darkBold16),
        ],
      ),
    );
  }

  Widget _buildResults(bool isSearching, List<String> results) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(16.h),
          LocalizedLabel(
            // وهو بيدور بيبقى "نتايج البحث"، وقبل ما يكتب نفس عنوان الهوم
            text: isSearching ? 'search_results' : 'cleaner_near_you',
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
            itemCount: results.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // لحد ما الداتا تيجي من الـ API، كل تالت مغسلة بتبقى مقفولة
              final isAvailable = index % 3 != 0;
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: CleanerItem(
                  onTap: () => context.push(AppRouter.laundryDetails),
                  image: Assets.assetsImagesCleaner,
                  name: results[index],
                  distance: 2.5,
                  isAvailable: isAvailable,
                  rating: 4.5,
                  ratingCount: 120,
                  pickUpTime: 'اليوم',
                  deliveryTime: 'غدا',
                  services: const ['Laundry', 'Dry Cleaning'],
                  deliveryPrice: 5.0,
                  workingHours: defaultWorkingHours,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
