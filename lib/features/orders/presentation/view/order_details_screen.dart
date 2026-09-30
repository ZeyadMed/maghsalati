import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/helpers/web_view_container.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/adjustment_review_sheet.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/confirm_dropoff_sheet.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_item_row.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_next_step_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_payment_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_progress_tracker.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_badge.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/rate_laundry_sheet.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_details_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';
import 'package:maghsalati/features/orders/presentation/view_model/payment_link_cubit.dart';

/// شاشة تفاصيل الطلب: بتتفتح برقم الطلب وبتجيبه من api/customer/orders/{id}
/// فوق حالة الطلب والخطوة الجاية (ولو فيه حاجة مطلوبة من العميل زرارها هنا)
/// والدفع، وتحت القطع والحساب
/// بتتحدث بالسحب، ولما التطبيق يرجع من الخلفية، ولما ييجي تحديث للطلب ده
class OrderDetailsScreen extends StatefulWidget {
  final OrderDetailsArgs args;

  const OrderDetailsScreen({super.key, required this.args});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  final OrderDetailsCubit _cubit = getIt<OrderDetailsCubit>();
  final PaymentLinkCubit _paymentCubit = getIt<PaymentLinkCubit>();
  late final StreamSubscription<int?> _updatesSubscription;

  int get _orderId => widget.args.orderId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit.load(_orderId, initial: widget.args.order);
    // إشعار أو أكشن غيّر الطلب ده (أو كل الطلبات لو الرقم null)
    _updatesSubscription = getIt<OrderUpdates>().stream.listen((orderId) {
      if (orderId == null || orderId == _orderId) _cubit.refresh();
    });
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
    _cubit.close();
    _paymentCubit.close();
    super.dispose();
  }

  /// بعد أي أكشن: الشاشة دي والليستة وشاشة الانتظار بيجيبوا الطلب تاني
  void _notifyOrderChanged() => getIt<OrderUpdates>().notify(_orderId);

  Future<void> _reviewAdjustment(OrderModel order) async {
    final approved = await AdjustmentReviewSheet.show(context, order);
    if (approved == null || !mounted) return;
    context.showSuccessMessage(
      (approved ? 'adjustment_approved' : 'adjustment_rejected').tr(),
    );
    // بعد الرد الطلب بيبقى InProgress ولينك الدفع بيتعمل، فكارت الدفع بيظهر
    _notifyOrderChanged();
  }

  /// لما اللينك يجهز الـ listener بيفتح صفحة الدفع
  void _pay(OrderModel order) => _paymentCubit.prepare(order);

  /// صفحة MyFatoorah بتقفل لوحدها لما توصل للـ callback أو الـ error،
  /// وبعدها بنجيب حالة الدفع الحقيقية من السيرفر بدل ما نعتمد على اللينك
  Future<void> _openPayment(String url) async {
    final finishedAt = await context.push<String>(
      AppRouter.webViewContainer,
      extra: WebViewArgs(
        url: url,
        title: 'payment',
        finishUrls: const [Endpoints.paymentCallback, Endpoints.paymentError],
      ),
    );
    if (finishedAt == null || !mounted) return;

    await _cubit.refresh();
    if (!mounted) return;
    _notifyOrderChanged();

    final status = _cubit.state.data?.paymentStatus;
    if (status == PaymentStatus.successful) {
      context.showSuccessMessage('payment_success'.tr());
    } else if (status == PaymentStatus.failed ||
        finishedAt.contains(Endpoints.paymentError)) {
      context.showErrorMessage('payment_failed_message'.tr());
    } else {
      context.showSuccessMessage(
        'payment_processing'.tr(),
        color: AppColors.orangeColor,
        icon: Icons.schedule_rounded,
      );
    }
  }

  Future<void> _confirmDropoff(OrderModel order) async {
    final confirmed = await ConfirmDropoffSheet.show(
      context,
      orderId: order.id,
      tripId: order.dropoffTripId ?? widget.args.deliveryTripId,
    );
    if (!confirmed || !mounted) return;
    context.showSuccessMessage('dropoff_confirmed'.tr());
    _notifyOrderChanged();
    // التقييم اختياري، فبنعرضه مرة واحدة بعد التسليم على طول
    if (order.laundryId > 0) _rateLaundry(order);
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
    return BlocListener<PaymentLinkCubit, BaseState<String>>(
      bloc: _paymentCubit,
      listenWhen: (previous, current) =>
          current.isSuccess || current.isFailure,
      listener: (context, state) {
        final url = state.data;
        if (state.isSuccess && url != null) _openPayment(url);
        if (state.isFailure) {
          context.showErrorMessage(state.errorMessage ?? 'try_again'.tr());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: CustomAppBar(
          title: 'order_details',
          backgroundColor: AppColors.secondaryColor,
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // التحديث وقع بس فيه نسخة قديمة معروضة، فبنقول ونسيبه يحاول تاني
          if (state.isFailure) ...[_buildRefreshFailed(state), Gap(8.h)],
          _buildInfoCard(context, order),
          Gap(14.h),
          OrderNextStepCard(
            order: order,
            onReviewAdjustment: () => _reviewAdjustment(order),
            onConfirmDropoff: () => _confirmDropoff(order),
            onRateLaundry: () => _rateLaundry(order),
            onChooseAnotherLaundry: () => context.go(AppRouter.initialRoot),
          ),
          if (order.status.isPaymentPhase) ...[
            Gap(14.h),
            BlocBuilder<PaymentLinkCubit, BaseState<String>>(
              bloc: _paymentCubit,
              builder: (context, paymentState) => OrderPaymentCard(
                order: order,
                isLoading: paymentState.isLoading,
                onPay: () => _pay(order),
              ),
            ),
          ],
          Gap(14.h),
          _buildItemsCard(order),
          Gap(14.h),
          _buildTotalsCard(order),
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

  /// كارت فوق: اسم المغسلة ورقم الطلب وتاريخه وحالته
  /// وشريط الخطوات بيبان بس لو الطلب لسه شغال
  Widget _buildInfoCard(BuildContext context, OrderModel order) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.laundryName,
                      style: TextStyles.darkBold16.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(4.h),
                    Text(
                      DateFormat(
                        'd MMMM yyyy',
                        context.locale.toString(),
                      ).format(order.date),
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor3,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(2.h),
                    Text(
                      '${'order_number'.tr()}: ${order.reference}',
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor3,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gap(12.w),
              OrderStatusBadge(status: order.status),
            ],
          ),
          if (order.isCurrent) ...[
            Gap(18.h),
            OrderProgressTracker(status: order.status),
          ],
        ],
      ),
    );
  }

  /// كارت القطع: كل قطعة بصورتها واسمها وكميتها وسعرها
  Widget _buildItemsCard(OrderModel order) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'order_items'.tr(),
                  style: TextStyles.darkBold16.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Gap(12.w),
              Text(
                '${order.totalPieces} ${'piece'.tr()}',
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
              ),
            ],
          ),
          Gap(14.h),
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

  /// كارت الحساب: مجموع القطع + رسوم الاستلام + رسوم التسليم
  /// وتحتهم الإجمالي النهائي زي ما السيرفر حسبه
  Widget _buildTotalsCard(OrderModel order) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAmountRow('items_total'.tr(), order.itemsTotal),
          Gap(10.h),
          _buildAmountRow('pickup_fee'.tr(), order.pickupFee),
          Gap(10.h),
          _buildAmountRow('dropoff_fee'.tr(), order.dropoffFee),
          Gap(12.h),
          Divider(height: 1.h, color: AppColors.lightGreyColor),
          Gap(12.h),
          _buildGrandTotalRow(order),
        ],
      ),
    );
  }

  /// سطر مبلغ عادي: اسمه على جنب وقيمته على التاني
  Widget _buildAmountRow(String label, num amount) {
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
          '${formatOrderPrice(amount)} ${'currency'.tr()}',
          style: TextStyles.darkBold14,
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

  /// نفس شكل كروت الطلبات عشان الشاشتين يبقوا متسقين
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
