import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/current_order_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/orders_header.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/orders_tabs_bar.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/previous_order_card.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';
import 'package:maghsalati/features/orders/presentation/view_model/orders_cubit.dart';

/// شاشة الطلبات بتابين: الحالية والسابقة
/// الطلبات بتيجي من api/customer/orders صفحة صفحة، والتابين بيتفلتروا
/// من نفس الطلبات اللي اتحملت
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersCubit _cubit = getIt<OrdersCubit>();
  late final StreamSubscription<int?> _updatesSubscription;
  late final StreamSubscription<OrderModel> _ordersSubscription;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _cubit.getOrders();
    // التاب عايش في IndexedStack، فبيتحدث لما طلب يتغير (إشعار أو أكشن أو
    // طلب جديد) أو لما اليوزر يرجعله من البوتوم ناف
    _updatesSubscription = getIt<OrderUpdates>().stream.listen(
      (_) => _cubit.getOrders(),
    );
    // الطلب كله جاي من الـ realtime، فبيتبدل مكانه من غير ما نجيب الليستة كلها
    _ordersSubscription = getIt<OrderUpdates>().orders.listen(
      _cubit.applyOrder,
    );
  }

  @override
  void dispose() {
    _updatesSubscription.cancel();
    _ordersSubscription.cancel();
    _cubit.close();
    super.dispose();
  }

  /// الطلب من الليستة بيتعرض على طول، والتفاصيل بتتجاب من السيرفر
  void _openDetails(OrderModel order) {
    context.push(
      AppRouter.orderDetails,
      extra: OrderDetailsArgs.fromOrder(order),
    );
  }

  /// بتتنادى بعد الفريم عشان الـ emit مايحصلش وسط الـ build
  void _loadMoreAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _cubit.loadMore());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: BlocBuilder<OrdersCubit, BaseState<OrderModel>>(
        bloc: _cubit,
        builder: (context, state) {
          final currentOrders = state.items
              .where((order) => order.isCurrent)
              .toList();
          final previousOrders = state.items
              .where((order) => !order.isCurrent)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OrdersHeader(),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: OrdersTabsBar(
                  selectedIndex: _selectedTab,
                  currentCount: currentOrders.length,
                  previousCount: previousOrders.length,
                  onTabSelected: (index) =>
                      setState(() => _selectedTab = index),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: _cubit.getOrders,
                  child: _buildBody(
                    state,
                    _selectedTab == 0 ? currentOrders : previousOrders,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BaseState<OrderModel> state, List<OrderModel> orders) {
    // أول تحميل أو فشل ومفيش طلبات قديمة نعرضها
    if (state.items.isEmpty) {
      if (state.isFailure) return _buildScrollableCenter(_buildError(state));
      if (!state.isSuccess) return _buildScrollableCenter(_buildLoading());
    }

    if (orders.isEmpty) {
      // التاب ده فاضي في الصفحات اللي اتحملت، بس ممكن يكون فيه طلبات
      // في الصفحات الجاية فبنكمل تحميل لحد ما الصفحات تخلص
      if (!state.hasReachedMax) {
        if (!state.isLoadingMoreFauilare) _loadMoreAfterFrame();
        return _buildScrollableCenter(_buildLoading());
      }
      return _buildScrollableCenter(_buildEmptyState());
    }

    final showLoader = !state.hasReachedMax;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: orders.length + (showLoader ? 1 : 0),
      separatorBuilder: (_, _) => Gap(14.h),
      itemBuilder: (context, index) {
        if (index == orders.length) {
          // اللودر آخر الليستة، أول ما يترسم بنجيب الصفحة اللي بعدها
          _loadMoreAfterFrame();
          return _buildLoading();
        }

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

  /// الحالات اللي في النص لازم تبقى جوه scrollable عشان السحب للتحديث يشتغل
  Widget _buildScrollableCenter(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildError(BaseState<OrderModel> state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 56.r, color: AppColors.greyColor5),
          Gap(12.h),
          Text(
            state.errorMessage ?? 'try_again'.tr(),
            style: TextStyles.darkBold16,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _cubit.getOrders,
            child: Text(
              'try_again'.tr(),
              style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
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
          style: TextStyles.darkRegular14.copyWith(color: AppColors.greyColor3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
