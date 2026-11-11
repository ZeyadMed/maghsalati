import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/gateway_payment.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/adjustment_review_sheet.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_completed_sheet.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_customer_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_help_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_item_row.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_laundry_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_next_step_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_notes_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_payment_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_progress_tracker.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_tracking_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/pay_order_sheet.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/rate_laundry_sheet.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_details_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';

/// شاشة تفاصيل الطلب: بتتفتح برقم الطلب وبتجيبه من api/customer/orders/{id}
/// الترتيب من فوق لتحت: الحالة الحالية (ولو فيه حاجة مطلوبة من العميل زرارها
/// هنا)، رقم الطلب وتاريخه وشريط المراحل، الخريطة ومندوب الاستلام ومندوب
/// التسليم كل واحد بحالته، المغسلة، بيانات العميل والعنوان، الصور والملاحظات،
/// القطع، طريقة الدفع، الحساب والفاتورة، وفي الآخر التواصل والمساعدة
/// بتتحدث بالسحب، ولما التطبيق يرجع من الخلفية، ولما ييجي تحديث للطلب ده
/// والـ realtime بيبعت الطلب كله فبيتعرض على طول، ولو المغسلة بعتت تعديل
/// شيت المراجعة بيتفتح لوحده. أي مبلغ مستحق (outstandingAmount) زراره في
/// كارت الخطوة الجاية، وبيفتح شيت الدفع (محفظة أو بوابة)
class OrderDetailsScreen extends StatefulWidget {
  final OrderDetailsArgs args;

  const OrderDetailsScreen({super.key, required this.args});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  final OrderDetailsCubit _cubit = getIt<OrderDetailsCubit>();
  late final StreamSubscription<int?> _updatesSubscription;
  late final StreamSubscription<OrderModel> _ordersSubscription;
  late final StreamSubscription<int> _adjustmentsSubscription;

  /// شيت الدفع أو صفحة البوابة مفتوحين، عشان الدفع مايبدأش مرتين
  bool _paying = false;

  /// عشان شيت التعديل مايتفتحش مرتين (من الزرار ومن الحدث)
  bool _adjustmentSheetOpen = false;

  /// شيت التهنئة بيتفتح مرة واحدة بس لما الطلب يبقى Delivered قدام العميل
  bool _completedSheetShown = false;

  /// الرحلات اللي العميل قيّم مندوبها من الشاشة دي، عشان الزرار يختفي على طول
  /// حتى لو السيرفر مابيبعتش isDriverReviewed
  final Set<int> _ratedDriverTrips = {};

  int get _orderId => widget.args.orderId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit.load(_orderId, initial: widget.args.order);
    // إشعار أو أكشن غيّر الطلب ده (أو كل الطلبات لو الرقم null)
    final updates = getIt<OrderUpdates>()..watch(_orderId);
    _updatesSubscription = updates.stream.listen((orderId) {
      if (orderId == null || orderId == _orderId) _cubit.refresh();
    });
    _ordersSubscription = updates.orders.listen(_onRealtimeOrder);
    _adjustmentsSubscription = updates.adjustments.listen((orderId) {
      if (orderId == _orderId) _onAdjustmentCreated();
    });
    // جاي من زرار الدفع في كارت الطلب، فشيت الدفع بيتفتح على طول
    final initial = widget.args.order;
    if (widget.args.openPayment && initial != null && initial.needsPayment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pay(_cubit.state.data ?? initial);
      });
    }
  }

  /// OrderUpdated للطلب ده: بيتعرض على طول. لو صفحة البوابة مفتوحة
  /// [GatewayPayment] هو اللي بيقفلها لما النتيجة توصل
  void _onRealtimeOrder(OrderModel order) {
    if (order.id != _orderId) return;
    _cubit.apply(order);
  }

  /// AdjustmentCreated: بيوصل بعد OrderUpdated بحالة AdjustmentPendingApproval
  /// فالطلب اللي معانا فيه التعديل غالبًا، ولو مش فيه بنجيبه الأول.
  /// الشيت بيتفتح بس لو الشاشة دي اللي قدام اليوزر (مش تحت صفحة الدفع مثلًا)
  Future<void> _onAdjustmentCreated() async {
    if (_adjustmentSheetOpen) return;
    var order = _cubit.state.data;
    if (order?.adjustment == null ||
        order!.status != OrderStatus.adjustmentPendingApproval) {
      await _cubit.refresh();
      order = _cubit.state.data;
    }
    if (!mounted || order == null) return;
    if (order.status != OrderStatus.adjustmentPendingApproval) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    _reviewAdjustment(order);
  }

  /// الحالة ممكن تكون اتغيرت واليوزر بره التطبيق، زي بعد مكالمة المندوب
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cubit.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updatesSubscription.cancel();
    _ordersSubscription.cancel();
    _adjustmentsSubscription.cancel();
    getIt<OrderUpdates>().unwatch(_orderId);
    _cubit.close();
    super.dispose();
  }

  /// بعد أي أكشن: الشاشة دي والليستة وشاشة الانتظار بيجيبوا الطلب تاني
  void _notifyOrderChanged() => getIt<OrderUpdates>().notify(_orderId);

  Future<void> _reviewAdjustment(OrderModel order) async {
    if (_adjustmentSheetOpen) return;
    _adjustmentSheetOpen = true;
    final approved = await AdjustmentReviewSheet.show(context, order);
    _adjustmentSheetOpen = false;
    if (approved == null || !mounted) return;
    context.showSuccessMessage(
      (approved ? 'adjustment_approved' : 'adjustment_rejected').tr(),
    );
    // بعد الرد الطلب بيبقى InProgress: لو السعر زاد فيه فرق مستحق وزرار
    // "ادفع الفرق" بيظهر، ولو قلّ الفرق رجع للمحفظة
    _notifyOrderChanged();
  }

  /// شيت الدفع بيبعت /pay بالطريقة اللي اختارها: المحفظة بتتسوّى على طول،
  /// والبوابة بترجع لينك بيتفتح في [GatewayPayment] وبعدها بنعرض النتيجة
  Future<void> _pay(OrderModel order) async {
    if (_paying || !order.needsPayment) return;
    _paying = true;
    try {
      final paid = await PayOrderSheet.show(context, order);
      if (paid == null || !mounted) return;
      _cubit.apply(paid);

      if (!paid.isPaid && paid.hasPaymentUrl) {
        final result = await GatewayPayment.open(
          context,
          orderId: _orderId,
          url: paid.paymentUrl!,
        );
        if (!mounted) return;
        if (result.order != null) _cubit.apply(result.order!);
        GatewayPayment.showOutcome(context, result);
        return;
      }
      context.showSuccessMessage('wallet_payment_success'.tr());
      _notifyOrderChanged();
    } finally {
      _paying = false;
    }
  }

  /// المندوب أكد التسليم والطلب بقى Delivered والشاشة دي قدام العميل
  /// (من الـ realtime أو التحديث): رسالة التهنئة مرة واحدة، ومنها العميل
  /// يختار يقيّم المغسلة أو المندوب أو يقفل
  Future<void> _onDelivered(OrderModel order) async {
    if (_completedSheetShown) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    _completedSheetShown = true;
    _notifyOrderChanged();
    final dropoffTrip = order.dropoffTrip;
    final canRateDriver =
        dropoffTrip != null &&
        !_isDriverRated(dropoffTrip) &&
        order.canRateDriver(dropoffTrip);
    final choice = await OrderCompletedSheet.show(
      context,
      canRateLaundry: order.laundryId > 0,
      canRateDriver: canRateDriver,
    );
    if (!mounted) return;
    switch (choice) {
      case OrderCompletedChoice.rateLaundry:
        _rateLaundry(order);
      case OrderCompletedChoice.rateDriver:
        _rateDriver(dropoffTrip!);
      case null:
        break;
    }
  }

  bool _isDriverRated(OrderTripModel trip) =>
      trip.isDriverReviewed == true || _ratedDriverTrips.contains(trip.id);

  Future<void> _rateDriver(OrderTripModel trip) async {
    final submitted = await context.push<bool>(
      AppRouter.rateDriver,
      extra: trip,
    );
    if (submitted != true || !mounted) return;
    setState(() => _ratedDriverTrips.add(trip.id));
    context.showSuccessMessage('review_submitted'.tr());
    _notifyOrderChanged();
  }

  Future<void> _rateLaundry(OrderModel order) async {
    final submitted = await RateLaundrySheet.show(
      context,
      laundryId: order.laundryId,
      laundryName: order.laundryName,
    );
    if (submitted && mounted) {
      context.showSuccessMessage('review_submitted'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // الطلب كان معروض بحالة تانية واتحول لـ Delivered (المندوب قفل الرحلة)
        BlocListener<OrderDetailsCubit, BaseState<OrderModel>>(
          bloc: _cubit,
          listenWhen: (previous, current) {
            final before = previous.data?.status;
            return before != null &&
                before != OrderStatus.delivered &&
                current.data?.status == OrderStatus.delivered;
          },
          listener: (context, state) => _onDelivered(state.data!),
        ),
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'order_details',
          backgroundColor: AppColors.scaffoldBackgroundColor,
        ),
        body: BlocBuilder<OrderDetailsCubit, BaseState<OrderModel>>(
          bloc: _cubit,
          builder: (context, state) {
            final order = state.data;
            if (order == null) {
              return state.isFailure
                  ? _buildError(state)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
            }
            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: _cubit.refresh,
              child: _buildContent(context, state, order),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BaseState<OrderModel> state,
    OrderModel order,
  ) {
    final driverTrips = order.driverTrips;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // التحديث وقع بس فيه نسخة قديمة معروضة، فبنقول ونسيبه يحاول تاني
          if (state.isFailure) ...[_buildRefreshFailed(state), Gap(8.h)],
          OrderNextStepCard(
            order: order,
            onReviewAdjustment: () => _reviewAdjustment(order),
            onPay: () => _pay(order),
            onRateLaundry: () => _rateLaundry(order),
            onChooseAnotherLaundry: () => context.go(AppRouter.initialRoot),
          ),
          Gap(14.h),
          _buildSummaryCard(context, order),
          if (driverTrips.isNotEmpty) ...[
            Gap(14.h),
            OrderTrackingCard(
              order: order,
              trips: driverTrips,
              onRateDriver: _rateDriver,
              isDriverRated: _isDriverRated,
            ),
          ],
          if (order.laundryName.isNotEmpty) ...[
            Gap(14.h),
            OrderLaundryCard(order: order),
          ],
          Gap(14.h),
          OrderCustomerCard(order: order),
          if (order.hasNotesOrImages) ...[
            Gap(14.h),
            OrderNotesCard(order: order),
          ],
          Gap(14.h),
          _buildItemsCard(order),
          if (OrderPaymentCard.isShownFor(order)) ...[
            Gap(14.h),
            OrderPaymentCard(order: order),
          ],
          Gap(14.h),
          _buildTotalsCard(context, order),
          Gap(14.h),
          OrderHelpCard(order: order),
        ],
      ),
    );
  }

  /// أول تحميل وقع ومفيش حاجة نعرضها
  Widget _buildError(BaseState<OrderModel> state) {
    return Center(
      child: Padding(
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
              onPressed: _cubit.refresh,
              child: Text(
                'try_again'.tr(),
                style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshFailed(BaseState<OrderModel> state) {
    return Row(
      children: [
        Icon(Icons.error_outline, size: 18.r, color: AppColors.redColor2),
        Gap(6.w),
        Expanded(
          child: Text(
            state.errorMessage ?? 'try_again'.tr(),
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.redColor2,
            ),
          ),
        ),
        TextButton(
          onPressed: _cubit.refresh,
          child: Text(
            'try_again'.tr(),
            style: TextStyles.boldStyle(12, color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  /// رقم الطلب وتاريخه، وتحتهم مراحل الطلب كلها بأسمائها.
  /// المرفوض والملغي مالهمش مراحل
  Widget _buildSummaryCard(BuildContext context, OrderModel order) {
    return OrderSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOrderNumber(context, order),
          if (order.currentStage != null) ...[
            Gap(14.h),
            Divider(height: 1.h, color: AppColors.lightGreyColor),
            Gap(16.h),
            OrderProgressTracker(order: order, showAllStages: true),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderNumber(BuildContext context, OrderModel order) {
    final date = DateFormat(
      'd MMMM yyyy - h:mm a',
      context.locale.toString(),
    ).format(order.date.toLocal());

    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            size: 22.r,
            color: AppColors.primaryColor,
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${'order_number'.tr()}: ${order.reference}',
                style: TextStyles.darkBold16,
              ),
              Gap(2.h),
              Text(
                date,
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
              ),
            ],
          ),
        ),
        Gap(8.w),
        OrderCircleButton(
          icon: Icons.copy_outlined,
          tooltip: 'copy'.tr(),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: order.reference));
            if (context.mounted) context.showSuccessMessage('copied'.tr());
          },
        ),
      ],
    );
  }

  /// كارت القطع: كل قطعة بصورتها واسمها وخدمتها وكميتها وسعرها
  Widget _buildItemsCard(OrderModel order) {
    return OrderSectionCard(
      title: 'order_items'.tr(),
      trailing: Text(
        '${order.totalPieces} ${'piece'.tr()}',
        style: TextStyles.darkRegular12.copyWith(color: AppColors.greyColor3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // الفاصل بيتحط بين القطع بس، مش تحت آخر واحدة
          for (int i = 0; i < order.items.length; i++) ...[
            if (i > 0) ...[
              Gap(12.h),
              Divider(height: 1.h, color: AppColors.lightGreyColor),
              Gap(12.h),
            ],
            OrderItemRow(item: order.items[i]),
          ],
        ],
      ),
    );
  }

  /// كارت الحساب: مجموع القطع + رسوم الاستلام + رسوم التسليم، ورسوم المنصة
  /// والخصم لو موجودين، وتحتهم الإجمالي النهائي زي ما السيرفر حسبه.
  /// الطلب المكتمل بيبان تحته زرار الفاتورة
  Widget _buildTotalsCard(BuildContext context, OrderModel order) {
    return OrderSectionCard(
      title: 'invoice'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAmountRow('items_total'.tr(), order.itemsTotal),
          Gap(10.h),
          _buildAmountRow('pickup_fee'.tr(), order.pickupFee),
          Gap(10.h),
          _buildAmountRow('dropoff_fee'.tr(), order.dropoffFee),
          if (order.platformFee > 0) ...[
            Gap(10.h),
            _buildAmountRow('invoice_platform_fee'.tr(), order.platformFee),
          ],
          if (order.discount > 0) ...[
            Gap(10.h),
            _buildAmountRow(
              'invoice_discount'.tr(),
              order.discount,
              isDiscount: true,
            ),
          ],
          Gap(12.h),
          Divider(height: 1.h, color: AppColors.lightGreyColor),
          Gap(12.h),
          _buildGrandTotalRow(order),
          if (order.hasInvoice) ...[
            Gap(14.h),
            SheetButton(
              label: 'view_invoice'.tr(),
              filled: false,
              onPressed: () =>
                  context.push(AppRouter.orderInvoice, extra: order),
            ),
          ],
        ],
      ),
    );
  }

  /// سطر مبلغ عادي: اسمه على جنب وقيمته على التاني، والخصم بالسالب وأحمر
  Widget _buildAmountRow(String label, num amount, {bool isDiscount = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyles.darkRegular14.copyWith(
              color: AppColors.greyColor2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(12.w),
        Text(
          '${isDiscount ? '- ' : ''}'
          '${formatOrderPrice(amount)} ${'currency'.tr()}',
          style: isDiscount
              ? TextStyles.darkBold14.copyWith(color: AppColors.redColor2)
              : TextStyles.darkBold14,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// الإجمالي النهائي بعد ما رسوم الاستلام والتسليم ينضافوا
  Widget _buildGrandTotalRow(OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'total'.tr(),
            style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(12.w),
        Text(
          '${formatOrderPrice(order.grandTotal)} ${'currency'.tr()}',
          style: TextStyles.blueBold20.copyWith(fontSize: 18.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
