import 'package:easy_localization/easy_localization.dart';
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
import 'package:maghsalati/features/home/presentation/view/widget/timing_row.dart';
import 'package:maghsalati/features/laundry_details/data/mock/mock_services_data.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/category_items_screen.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/laundry_details_header.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/order_summary_bar.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/services_section.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';

class LaundryDetails extends StatefulWidget {
  final dynamic image;
  final String name;
  final double rating;
  final int ratingCount;

  /// سعر التوصيل، بيتعرض في بوكس التوصيل وبينضاف على الإجمالي تحت
  final num deliveryPrice;

  /// الأقسام بتيجي من ال endpoint وتتبعت هنا، مفيش حاجة ثابتة في الشاشة
  /// ولو مااتبعتش بتتعرض داتا تجريبية لحد ما ال endpoint يجهز
  final List<ServiceCategoryModel>? categories;

  const LaundryDetails({
    super.key,
    this.image = Assets.assetsImagesCleaner,
    this.name = 'مغسلة النخبة',
    this.rating = 4.8,
    this.ratingCount = 312,
    this.deliveryPrice = 8.0,
    this.categories,
  });

  @override
  State<LaundryDetails> createState() => _LaundryDetailsState();
}

class _LaundryDetailsState extends State<LaundryDetails> {
  /// بيمسك الكميات المختارة، والشاشة تقدر تقرا منه الطلب كله وقت الإرسال
  /// جاي من get_it عشان السلة تفضل عايشة لما تخرج من الشاشة ويشوفها تاب السلة
  final SelectedServicesController _servicesController =
      getIt<SelectedServicesController>();

  /// بنبنيها مرة واحدة عشان ماتتعادش في كل build
  late final List<ServiceCategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    // TODO: امسح الـ MockServicesData لما ال endpoint يجهز
    _categories = widget.categories ?? MockServicesData.categories;
    // السلة لمغسلة واحدة بس، فلو فيها حاجة من مغسلة تانية بنسأل الأول
    if (_servicesController.belongsToOtherLaundry(widget.name)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _askToReplaceCart();
      });
    } else {
      _prepareCart();
    }
  }

  /// بتجهز السلة للمغسلة دي: الأسعار والأقسام واسم المغسلة وسعر التوصيل
  void _prepareCart() {
    // الأسعار بتتحمل مرة واحدة عشان البار تحت يحسب الإجمالي لوحده
    _servicesController.loadPrices(_categories);
    _servicesController.setLaundryName(widget.name);
    _servicesController.setDeliveryPrice(widget.deliveryPrice);
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
                  ServicesSection(
                    categories: _categories,
                    controller: _servicesController,
                    onCategoryTap: _openCategory,
                  ),
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
