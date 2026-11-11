import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/payment_method.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/wallet/presentation/view/widget/redeem_code_sheet.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';

/// اختيار طريقة الدفع (المحفظة أو البوابة) في تأكيد الطلب وفي دفع المستحق.
/// المحفظة بيبان جنبها الرصيد، ولو الرصيد أقل من [amount] بيظهر تنبيه
/// وزرار شحن بكود. الرصيد من [WalletBalanceCubit] المشترك، والشاشة اللي
/// فيها الاختيار هي اللي بتنادي load
class PaymentMethodSelector extends StatelessWidget {
  /// null لحد ما العميل يختار، وساعتها بيتعرض [effectiveMethod]
  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod> onChanged;

  /// المبلغ اللي هيتدفع، عشان نعرف الرصيد كفاية ولا لأ
  final num amount;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.amount,
  });

  /// اللي العميل اختاره، ولو لسه ماختارش: المحفظة لو رصيدها يكفي وإلا البوابة
  static PaymentMethod effectiveMethod(PaymentMethod? selected, num amount) {
    if (selected != null) return selected;
    final balance = getIt<WalletBalanceCubit>().balance;
    return balance != null && balance >= amount
        ? PaymentMethod.wallet
        : PaymentMethod.gateway;
  }

  /// المحفظة متختارة والرصيد معروف وأقل من المبلغ، فالدفع هيترفض من السيرفر
  static bool isWalletShort(PaymentMethod? selected, num amount) {
    if (effectiveMethod(selected, amount) != PaymentMethod.wallet) return false;
    final balance = getIt<WalletBalanceCubit>().balance;
    return balance != null && balance < amount;
  }

  Future<void> _recharge(BuildContext context) async {
    final result = await RedeemCodeSheet.show(context);
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(
      'redeem_success'.tr(
        args: ['${formatOrderPrice(result.amount)} ${'currency'.tr()}'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = getIt<WalletBalanceCubit>();

    return BlocBuilder<WalletBalanceCubit, BaseState<num>>(
      bloc: wallet,
      builder: (context, state) {
        final method = effectiveMethod(selected, amount);
        final balance = state.data;
        final short =
            method == PaymentMethod.wallet &&
            balance != null &&
            balance < amount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MethodTile(
              method: PaymentMethod.wallet,
              selected: method == PaymentMethod.wallet,
              subtitle: _walletSubtitle(state),
              subtitleColor: short ? AppColors.redColor2 : null,
              trailing: balance == null && state.isFailure
                  ? IconButton(
                      onPressed: wallet.load,
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 20.r,
                        color: AppColors.primaryColor,
                      ),
                      tooltip: 'try_again'.tr(),
                    )
                  : null,
              onTap: () => onChanged(PaymentMethod.wallet),
            ),
            Gap(10.h),
            _MethodTile(
              method: PaymentMethod.gateway,
              selected: method == PaymentMethod.gateway,
              subtitle: 'payment_method_gateway_hint'.tr(),
              onTap: () => onChanged(PaymentMethod.gateway),
            ),
            if (short) ...[Gap(10.h), _buildShortBalance(context)],
          ],
        );
      },
    );
  }

  String _walletSubtitle(BaseState<num> state) {
    final balance = state.data;
    if (balance != null) {
      return 'wallet_available_balance'.tr(
        args: ['${formatOrderPrice(balance)} ${'currency'.tr()}'],
      );
    }
    if (state.isFailure) return state.errorMessage ?? 'try_again'.tr();
    return 'wallet_balance_loading'.tr();
  }

  /// الرصيد مش كفاية: يشحن بكود أو يختار البوابة
  Widget _buildShortBalance(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.orangeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.r,
            color: AppColors.orangeColor,
          ),
          Gap(8.w),
          Expanded(
            child: Text(
              'wallet_insufficient_balance'.tr(),
              style: TextStyles.darkRegular12,
            ),
          ),
          TextButton(
            onPressed: () => _recharge(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size(0, 32.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'recharge_wallet'.tr(),
              style: TextStyles.darkBold14.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// كارت طريقة واحدة بأيقونتها واسمها وسطر تحتها، والمختارة بإطار ملون
class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final String subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.subtitle,
    required this.onTap,
    this.subtitleColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryColor : AppColors.greyColor4;

    return Material(
      color: selected
          ? AppColors.primaryColor.withValues(alpha: 0.06)
          : AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: selected ? AppColors.primaryColor : AppColors.borderColor,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method.icon,
                  size: 20.r,
                  color: AppColors.primaryColor,
                ),
              ),
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(method.labelKey.tr(), style: TextStyles.darkBold14),
                    Gap(2.h),
                    Text(
                      subtitle,
                      style: TextStyles.darkRegular12.copyWith(
                        color: subtitleColor ?? AppColors.greyColor3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ?trailing,
              Gap(4.w),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 22.r,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
