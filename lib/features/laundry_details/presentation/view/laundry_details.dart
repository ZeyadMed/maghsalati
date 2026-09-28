import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/loading_shimmer.dart';
import 'package:maghsalati/features/home/presentation/view/widget/timing_row.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/category_items_screen.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/laundry_details_header.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/order_summary_bar.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/services_section.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/working_hours_button.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/laundry_services_cubit.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';

class LaundryDetails extends StatefulWidget {
  /// الأقسام والقطع بتتجاب بيه من api/customer/laundries/{laundryId}/services
  final int laundryId;
  final dynamic image;
  final String name;
  final double rating;
  final int ratingCount;

  /// سعر التوصيل، بيتعرض في بوكس التوصيل وبينضاف على الإجمالي تحت
  final num deliveryPrice;

  const LaundryDetails({
    super.key,
    required this.laundryId,
    this.image = Assets.assetsImagesCleaner,
    this.name = 'مغسلة النخبة',
    this.rating = 4.8,
    this.ratingCount = 312,
    this.deliveryPrice = 8.0,
  });

  @override
  State<LaundryDetails> createState() => _LaundryDetailsState();
}

class _LaundryDetailsState extends State<LaundryDetails> {
  /// بيمسك الكميات المختارة، والشاشة تقدر تقرا منه الطلب كله وقت الإرسال
  /// جاي من get_it عشان السلة تفضل عايشة لما تخرج من الشاشة ويشوفها تاب السلة
  final SelectedServicesController _servicesController =
      getIt<SelectedServicesController>();

  final LaundryServicesCubit _servicesCubit = getIt<LaundryServicesCubit>();

  /// الأقسام اللي رجعت من ال endpoint، فاضية لحد ما الطلب يخلص
  List<ServiceCategoryModel> _categories = const [];

  /// السلة بقت بتاعة المغسلة دي (يا فاضية يا اليوزر وافق يمسح القديم)
  /// ومن غيرها مانحملش الأسعار عشان مانبوظش سلة مغسلة تانية
  bool _cartReady = false;

  @override
  void initState() {
    super.initState();
    _servicesCubit.getServices(widget.laundryId);
    // السلة لمغسلة واحدة بس، فلو فيها حاجة من مغسلة تانية بنسأل الأول
    if (_servicesController.belongsToOtherLaundry(widget.name)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _askToReplaceCart();
      });
    } else {
      _prepareCart();
    }
  }

  @override
  void dispose() {
    _servicesCubit.close();
    super.dispose();
  }

  /// بتجهز السلة للمغسلة دي: الأسعار والأقسام واسم المغسلة وسعر التوصيل
  void _prepareCart() {
    _cartReady = true;
    _servicesController.setLaundryName(widget.name);
    _servicesController.setDeliveryPrice(widget.deliveryPrice);
    _loadPrices();
  }

  /// الأسعار محتاجة الأقسام توصل من ال endpoint والسلة تكون جاهزة،
  /// فبتتنادى من المكانين وبتشتغل لما الاتنين يحصلوا
  void _loadPrices() {
    if (!_cartReady || _categories.isEmpty) return;
    _servicesController.loadPrices(_categories);
  }

  void _onServicesLoaded(List<ServiceCategoryModel> categories) {
    _categories = categories;
    _loadPrices();
  }

  /// لما يفتح مغسلة تانية والسلة لسه فيها حاجات من مغسلة قبلها
  /// يا إما يمسح ويكمل هنا، يا إما يرجع لمغسلته الأولى
  Future<void> _askToReplaceCart() async {
    final previousLaundry = _servicesController.laundryName;

    final replace = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('replace_cart_title'.tr(), style: TextStyles.darkBold16),
        content: Text(
          'replace_cart_message'.tr(args: [previousLaundry]),
          style: TextStyles.greyColor2Regular14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'cancel'.tr(),
              style: TextStyles.greyColor2Regular14,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'replace_cart_confirm'.tr(),
              style: TextStyles.darkBold14.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (replace ?? false) {
      _servicesController.clear();
      _prepareCart();
    } else {
      // رجعه للمغسلة اللي سلته منها بدل ما يفضل في شاشة سلتها مش بتاعتها
      Navigator.of(context).maybePop();
    }
  }

  /// بيفتح شاشة القطع وهي واقفة على القسم اللي اتداس عليه
  /// الكنترولر بيتبعت زي ما هو فالسلة مشتركة بين الشاشتين
  void _openCategory(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryItemsScreen(
          categories: _categories,
          controller: _servicesController,
          title: widget.name,
          initialIndex: index,
          // إتمام الطلب من شيت السلة بيقفل شاشة القطع الأول عشان لما يرجع
          // من شاشة الانتظار يلاقي نفسه في شاشة التفاصيل
          onConfirmOrder: () {
            Navigator.of(context).maybePop();
            _onConfirmOrder();
          },
        ),
      ),
    );
  }

  /// بيبني الطلب من الكميات المختارة ويودّي على شاشة انتظار موافقة المغسلة
  /// TODO: ابعت الطلب على ال endpoint هنا الأول لما يجهز
  void _onConfirmOrder() {
    final selected = _servicesController.selectedServices(_categories);
    if (selected.isEmpty) return;

    final order = PendingOrderModel(
      laundryName: widget.name,
      deliveryPrice: widget.deliveryPrice,
      lines: selected
          .map(
            (service) => PendingOrderLine(
              itemId: service.item.id,
              name: service.item.name,
              quantity: service.quantity,
              price: service.item.price,
            ),
          )
          .toList(),
    );

    context.push(AppRouter.orderPending, extra: order);
  }

  /// جريد الأقسام بيستنى ال endpoint، والـ listener بيحفظ الأقسام ويحمل الأسعار
  /// مرة واحدة لما توصل بدل ما يحصل ده جوا الـ build
  Widget _buildServices() {
    return BlocConsumer<LaundryServicesCubit, BaseState<ServiceCategoryModel>>(
      bloc: _servicesCubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => _onServicesLoaded(state.items),
      builder: (context, state) {
        if (state.isInitial || state.isLoading) return _buildServicesLoading();
        if (state.isFailure) {
          return _buildServicesMessage(
            icon: Icons.error_outline,
            text: state.errorMessage ?? 'try_again',
            onRetry: () => _servicesCubit.getServices(widget.laundryId),
          );
        }
        if (state.items.isEmpty) {
          return _buildServicesMessage(
            icon: Icons.local_laundry_service_outlined,
            text: 'no_services',
          );
        }

        return ServicesSection(
          categories: state.items,
          controller: _servicesController,
          onCategoryTap: _openCategory,
        );
      },
    );
  }

  Widget _buildServicesLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 8,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) => ShimmerBox(
        height: double.infinity,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildServicesMessage({
    required IconData icon,
    required String text,
    VoidCallback? onRetry,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56.r, color: AppColors.greyColor5),
          Gap(12.h),
          LocalizedLabel(
            text: text,
            style: TextStyles.darkBold16,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: LocalizedLabel(
                text: 'try_again',
                style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      // الصورة لازم توصل لحد فوق خالص تحت الاستاتس بار
      extendBodyBehindAppBar: true,
      // ثابت تحت الصفحة، والإجمالي جواه بيتغير مع كل قطعة تتختار
      bottomNavigationBar: OrderSummaryBar(
        controller: _servicesController,
        onConfirm: _onConfirmOrder,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LaundryDetailsHeader(
              image: widget.image,
              name: widget.name,
              rating: widget.rating,
              ratingCount: widget.ratingCount,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(16.h),
                  TimingRow(
                    pickUpTime: 'اليوم',
                    deliveryTime: 'غدا',
                    showDeliveryPrice: true,
                    deliveryPrice: widget.deliveryPrice,
                  ),
                  Gap(10.h),
                  WorkingHoursButton(
                    laundryId: widget.laundryId,
                    laundryName: widget.name,
                  ),
                  Gap(16.h),
                  LocalizedLabel(
                    text: 'choose_services',
                    style: TextStyles.blackBold16.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  Gap(12.h),
                  _buildServices(),
                  Gap(16.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
