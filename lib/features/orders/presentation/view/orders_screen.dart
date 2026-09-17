import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/mock/mock_orders_data.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/order_details_screen.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/current_order_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/orders_header.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/orders_tabs_bar.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/previous_order_card.dart';

/// شاشة الطلبات بتابين: الحالية والسابقة
/// الطلبات بتيجي من ال endpoint وتتبعت هنا، ولو مااتبعتش بتتعرض داتا تجريبية
class OrdersScreen extends StatefulWidget {
  final List<OrderModel>? orders;

  const OrdersScreen({super.key, this.orders});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0;

  /// بنفلترها مرة واحدة عشان ماتتفلترش في كل build
  late final List<OrderModel> _currentOrders;
  late final List<OrderModel> _previousOrders;

  @override
  void initState() {
    super.initState();
    // TODO: امسح الـ MockOrdersData لما ال endpoint يجهز
    final orders = widget.orders ?? MockOrdersData.orders;
    _currentOrders = orders.where((order) => order.isCurrent).toList();
    _previousOrders = orders.where((order) => !order.isCurrent).toList();
  }

  /// الطلبات المعروضة حسب التاب المختار
  List<OrderModel> get _visibleOrders =>
      _selectedTab == 0 ? _currentOrders : _previousOrders;

  void _openDetails(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OrdersHeader(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: OrdersTabsBar(
              selectedIndex: _selectedTab,
              currentCount: _currentOrders.length,
              previousCount: _previousOrders.length,
              onTabSelected: (index) => setState(() => _selectedTab = index),
            ),
          ),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final orders = _visibleOrders;
    if (orders.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: orders.length,
      separatorBuilder: (_, _) => Gap(14.h),
      itemBuilder: (context, index) {
        final order = orders[index];
        // كل تاب ليها شكل كارت مختلف، الحالية بشريط خطوات والسابقة من غيره
        return _selectedTab == 0
            ? CurrentOrderCard(
                order: order,
                onDetailsTap: () => _openDetails(order),
              )
            : PreviousOrderCard(
                order: order,
                onDetailsTap: () => _openDetails(order),
              );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56.r,
            color: AppColors.greyColor4,
          ),
          Gap(12.h),
          Text(
            _selectedTab == 0
                ? 'no_current_orders'.tr()
                : 'no_previous_orders'.tr(),
            style: TextStyles.darkRegular14.copyWith(
              color: AppColors.greyColor3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
