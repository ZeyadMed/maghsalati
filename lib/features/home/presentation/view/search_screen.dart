import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/home/presentation/view/widget/home_header.dart';
import 'package:maghsalati/features/home/presentation/view/widget/nearby_laundries_list.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/home/presentation/view_model/nearby_laundries_cubit.dart';

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

  /// نفس اند بوينت الهوم، بس بيتبعت معاه النص اللي بيتكتب في search
  late final NearbyLaundriesCubit _laundriesCubit =
      getIt<NearbyLaundriesCubit>()..start();

  /// النص اللي بيتكتب دلوقتي
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _laundriesCubit.close();
    // الكنترولر مش بيتعمله dispose هنا لأنه singleton في get_it
    super.dispose();
  }

  /// بيتنادى من البوتوم ناف أول ما التاب ده يتفتح عشان الكيبورد يطلع
  void focusSearch() {
    if (mounted) _searchFocusNode.requestFocus();
  }

  void _onSearchChanged(String? value) {
    setState(() => _query = (value ?? '').trim());
    _laundriesCubit.search(_query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _laundriesCubit,
      child: Scaffold(
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
                child: _buildResults(_query.isNotEmpty),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(bool isSearching) {
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
          NearbyLaundriesList(
            emptyText: isSearching
                ? 'no_search_results'
                : 'no_nearby_laundries',
          ),
        ],
      ),
    );
  }
}
