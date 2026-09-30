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
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/confirm_cart_bottom_sheet.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/category_items_screen.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/laundry_details_header.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/order_summary_bar.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/reviews_button.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/services_section.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/working_hours_button.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/laundry_services_cubit.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';

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

  /// سلة السيرفر، منها بادج الأقسام والإجمالي اللي في البار تحت
  /// singleton ومشترك مع تاب السلة، فمش بيتعمله close هنا
  final CartCubit _cartCubit = getIt<CartCubit>();

  /// الأقسام اللي رجعت من ال endpoint، فاضية لحد ما الطلب يخلص
  List<ServiceCategoryModel> _categories = const [];

  /// السلة بقت بتاعة المغسلة دي (يا فاضية يا اليوزر وافق يمسح القديم)
  /// ومن غيرها مانحملش الأسعار عشان مانبوظش سلة مغسلة تانية
  bool _cartReady = false;

  @override
  void initState() {
    super.initState();
    _servicesCubit.getServices(widget.laundryId);
    // بعد الفريم عشان ديالوج الاستبدال مايتفتحش جوه initState
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCartLaundry());
  }

  /// السلة لمغسلة واحدة بس، والسيرفر هو اللي بيرفض الإضافة من مغسلة تانية
  /// فبنقارن بسلة السيرفر مش باللي على الموبايل، ولو لسه ماتحملتش بنستناها
  Future<void> _checkCartLaundry() async {
    if (_cartCubit.state.data == null) await _cartCubit.getCart();
    if (!mounted) return;

    final cart = _cartCubit.state.data;
    if (cart != null && !cart.isEmpty && !_isThisLaundry(cart)) {
      _askToReplaceCart(cart.laundryName);
    } else {
      _prepareCart();
    }
  }

  /// لو السيرفر مابعتش laundryId بنقارن بالاسم
  bool _isThisLaundry(CartModel cart) => cart.laundryId > 0
      ? cart.laundryId == widget.laundryId
      : cart.laundryName == widget.name;

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
  Future<void> _askToReplaceCart(String previousLaundry) async {
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
            child: Text('cancel'.tr(), style: TextStyles.greyColor2Regular14),
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
      // سلة السيرفر لازم تتمسح هي كمان، وإلا أول إضافة هنا هتترفض
      await _cartCubit.clearCart();
      _servicesController.clear();
      if (mounted) _prepareCart();
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
          // والطلب بيتبني من سلة السيرفر اللي في الشيت، بعد ما بيانات
          // الاستلام تتبعت والسيرفر يأكده
          onConfirmOrder: (cart) async {
            final orderId = await ConfirmCartBottomSheet.show(context);
            if (orderId == null || !mounted) return;
            Navigator.of(context).maybePop();
            context.push(
              AppRouter.orderPending,
              extra: cart.toPendingOrder(orderId: orderId),
            );
          },
        ),
      ),
    );
  }

  /// بيفتح شيت بيانات الاستلام، ولما السيرفر يأكد الطلب بيودّي على شاشة
  /// انتظار موافقة المغسلة ومعاه رقم الطلب (الشيت نفسه بيحدث السلة)
  Future<void> _confirmCart(CartModel cart) async {
    final orderId = await ConfirmCartBottomSheet.show(context);
    if (orderId == null || !mounted) return;
    context.push(
      AppRouter.orderPending,
      extra: cart.toPendingOrder(orderId: orderId),
    );
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
          cartCubit: _cartCubit,
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
        cartCubit: _cartCubit,
        laundryId: widget.laundryId,
        onConfirm: _confirmCart,
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
                  // بوكسات "استلام اليوم / تسليم غدًا" اتشالت لأن مفيش مواعيد
                  // في السايكل، الاستلام بيبدأ لما مندوب يتعيّن على الرحلة
                  Gap(16.h),
                  WorkingHoursButton(
                    laundryId: widget.laundryId,
                    laundryName: widget.name,
                  ),
                  Gap(10.h),
                  ReviewsButton(
                    laundryId: widget.laundryId,
                    laundryName: widget.name,
                    rating: widget.rating,
                    ratingCount: widget.ratingCount,
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
