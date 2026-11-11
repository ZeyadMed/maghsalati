import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_payment_cubit.dart';
import 'package:maghsalati/features/wallet/presentation/view/widget/payment_method_selector.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';

/// شيت دفع المستحق على الطلب (الدفع المبدئي أو فرق المطابقة): المبلغ واختيار
/// الطريقة، وبيبعت على api/customer/orders/{id}/pay. بيرجع الطلب بعد الدفع
/// (بالبوابة فيه paymentUrl لسه هيتفتح)، و null لو قفل من غير دفع.
/// أخطاء السيرفر (الرصيد مش كفاية مثلًا) بتتعرض جوه الشيت
class PayOrderSheet extends StatefulWidget {
  final OrderModel order;

  const PayOrderSheet({super.key, required this.order});

  static Future<OrderModel?> show(BuildContext context, OrderModel order) =>
      showOrderSheet<OrderModel>(context, PayOrderSheet(order: order));

  @override
  State<PayOrderSheet> createState() => _PayOrderSheetState();
}

class _PayOrderSheetState extends State<PayOrderSheet> {
  final OrderPaymentCubit _cubit = getIt<OrderPaymentCubit>();

  /// null لحد ما العميل يختار، والافتراضي من [PaymentMethodSelector.effectiveMethod]
  PaymentMethod? _method;

  num get _amount => widget.order.amountDue;

  @override
  void initState() {
    super.initState();
    getIt<WalletBalanceCubit>().load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _pay() {
    _cubit.pay(
      widget.order.id,
      PaymentMethodSelector.effectiveMethod(_method, _amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return BlocConsumer<OrderPaymentCubit, BaseState<OrderModel>>(
      bloc: _cubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => Navigator.of(context).pop(state.data),
      builder: (context, state) => OrderSheetFrame(
        icon: Icons.payments_outlined,
        title:
            (order.isDifferenceDue ? 'pay_difference_title' : 'pay_order_title')
                .tr(),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetErrorText(
              message: state.isFailure
                  ? state.errorMessage ?? 'try_again'.tr()
                  : null,
            ),
            // الرصيد بيتحدث من الشحن جوه الاختيار، فالزرار بيتبني معاه
            BlocBuilder<WalletBalanceCubit, BaseState<num>>(
              bloc: getIt<WalletBalanceCubit>(),
              builder: (context, _) => SheetButton(
                label:
                    '${order.payActionKey.tr()} • '
                    '${formatOrderPrice(_amount)} ${'currency'.tr()}',
                isLoading: state.isLoading,
                onPressed: PaymentMethodSelector.isWalletShort(_method, _amount)
                    ? null
                    : _pay,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAmount(order),
            Gap(16.h),
            Text('payment_method'.tr(), style: TextStyles.darkBold14),
            Gap(8.h),
            PaymentMethodSelector(
              selected: _method,
              amount: _amount,
              onChanged: (method) => setState(() => _method = method),
            ),
          ],
        ),
      ),
    );
  }

  static String? _noteKey(OrderModel order) {
    if (order.status == OrderStatus.pendingPayment) {
      return 'next_step_pending_payment_body';
    }
    return order.isDifferenceDue ? 'next_step_difference_due_body' : null;
  }

  /// المبلغ المستحق، وتحته ليه: فرق مطابقة ولا الطلب لسه ماوصلش المغسلة
  Widget _buildAmount(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'amount_due'.tr(),
                  style: TextStyles.darkRegular14.copyWith(
                    color: AppColors.greyColor2,
                  ),
                ),
              ),
              Text(
                '${formatOrderPrice(_amount)} ${'currency'.tr()}',
                style: TextStyles.blueBold20.copyWith(fontSize: 18.sp),
              ),
            ],
          ),
          if (_noteKey(order) case final noteKey?) ...[
            Gap(6.h),
            Text(
              noteKey.tr(),
              style: TextStyles.darkRegular12.copyWith(
                color: AppColors.greyColor3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
