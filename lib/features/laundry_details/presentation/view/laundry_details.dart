import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/router/app_router.dart';
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
  late final SelectedServicesController _servicesController;

  /// بنبنيها مرة واحدة عشان ماتتعادش في كل build
  late final List<ServiceCategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _servicesController = SelectedServicesController();
    // TODO: امسح الـ MockServicesData لما ال endpoint يجهز
    _categories = widget.categories ?? MockServicesData.categories;
    // الأسعار بتتحمل مرة واحدة عشان البار تحت يحسب الإجمالي لوحده
    _servicesController.loadPrices(_categories);
    _servicesController.setDeliveryPrice(widget.deliveryPrice);
  }

  @override
  void dispose() {
    _servicesController.dispose();
    super.dispose();
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
