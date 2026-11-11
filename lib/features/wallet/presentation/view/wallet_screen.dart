import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/wallet/data/model/wallet_transaction_model.dart';
import 'package:maghsalati/features/wallet/presentation/view/widget/redeem_code_sheet.dart';
import 'package:maghsalati/features/wallet/presentation/view/widget/wallet_transaction_tile.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_transactions_cubit.dart';

/// شاشة المحفظة: الرصيد وزرار الشحن بكود فوق، وتحتهم حركات المحفظة صفحة صفحة
/// (شحن، دفع طلب، استرجاع فرق). الحركة المربوطة بطلب بتفتح تفاصيله
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  /// singleton في get_it فمش بيتعمله close هنا
  final WalletBalanceCubit _balance = getIt<WalletBalanceCubit>();
  final WalletTransactionsCubit _transactions =
      getIt<WalletTransactionsCubit>();

  @override
  void initState() {
    super.initState();
    _balance.load();
    _transactions.load();
  }

  @override
  void dispose() {
    _transactions.close();
    super.dispose();
  }

  Future<void> _refresh() =>
      Future.wait([_balance.load(), _transactions.load()]);

  /// الرصيد بيتحدث من رد الشحن، والحركات بنجيبها تاني عشان الشحن يظهر فيها
  Future<void> _recharge() async {
    final result = await RedeemCodeSheet.show(context);
    if (result == null || !mounted) return;
    context.showSuccessMessage(
      'redeem_success'.tr(
        args: ['${formatOrderPrice(result.amount)} ${'currency'.tr()}'],
      ),
    );
    _transactions.load();
  }

  void _openOrder(int orderId) {
    context.push(
      AppRouter.orderDetails,
      extra: OrderDetailsArgs(orderId: orderId),
    );
  }

  /// بتتنادى بعد الفريم عشان الـ emit مايحصلش وسط الـ build
  void _loadMoreAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _transactions.loadMore(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'my_wallet',
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _refresh,
        child:
            BlocBuilder<
              WalletTransactionsCubit,
              BaseState<WalletTransactionModel>
            >(
              bloc: _transactions,
              builder: (context, state) => _buildList(state),
            ),
      ),
    );
  }

  Widget _buildList(BaseState<WalletTransactionModel> state) {
    final transactions = state.items;
    final showLoader = transactions.isNotEmpty && !state.hasReachedMax;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        _BalanceCard(cubit: _balance, onRecharge: _recharge),
        Gap(10.h),
        _buildRefundNote(),
        Gap(20.h),
        Text('wallet_transactions'.tr(), style: TextStyles.darkBold16),
        Gap(10.h),
        if (transactions.isEmpty)
          _buildEmptyOrState(state)
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int i = 0; i < transactions.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: AppColors.lightGreyColor,
                    ),
                  WalletTransactionTile(
                    transaction: transactions[i],
                    onOpenOrder: transactions[i].orderId == null
                        ? null
                        : () => _openOrder(transactions[i].orderId!),
                  ),
                ],
              ],
            ),
          ),
        if (showLoader) _buildLoadMore(state),
      ],
    );
  }

  /// آخر الليستة: أول ما اللودر يترسم بنجيب الصفحة اللي بعدها،
  /// ولو وقعت زرار يحاول تاني
  Widget _buildLoadMore(BaseState<WalletTransactionModel> state) {
    if (state.isLoadingMoreFauilare) {
      return TextButton(
        onPressed: _transactions.loadMore,
        child: Text(
          'try_again'.tr(),
          style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
        ),
      );
    }
    _loadMoreAfterFrame();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildEmptyOrState(BaseState<WalletTransactionModel> state) {
    if (state.isFailure) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          children: [
            Text(
              state.errorMessage ?? 'try_again'.tr(),
              style: TextStyles.darkRegular14,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: _transactions.load,
              child: Text(
                'try_again'.tr(),
                style: TextStyles.boldStyle(14, color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      );
    }
    if (!state.isSuccess) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 52.r,
            color: AppColors.greyColor5,
          ),
          Gap(10.h),
          Text('wallet_no_transactions'.tr(), style: TextStyles.darkBold14),
          Gap(4.h),
          Text(
            'wallet_no_transactions_hint'.tr(),
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.greyColor3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// لو سعر الطلب قلّ بعد المطابقة، الفرق بيرجع هنا لوحده
  Widget _buildRefundNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16.r, color: AppColors.primaryColor),
        Gap(6.w),
        Expanded(
          child: Text(
            'wallet_refund_note'.tr(),
            style: TextStyles.greyColor2Regular14.copyWith(fontSize: 12.sp),
          ),
        ),
      ],
    );
  }
}

/// كارت الرصيد بلون البراند وتحته زرار الشحن بكود
class _BalanceCard extends StatelessWidget {
  final WalletBalanceCubit cubit;
  final VoidCallback onRecharge;

  const _BalanceCard({required this.cubit, required this.onRecharge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.primaryColor, AppColors.lightBlueColor2],
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 20.r,
                color: AppColors.whiteColor,
              ),
              Gap(8.w),
              Text(
                'wallet_balance'.tr(),
                style: TextStyles.whiteBold14.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Gap(10.h),
          BlocBuilder<WalletBalanceCubit, BaseState<num>>(
            bloc: cubit,
            builder: (context, state) => _buildBalance(state),
          ),
          Gap(16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRecharge,
              icon: Icon(
                Icons.card_giftcard_rounded,
                size: 18.r,
                color: AppColors.primaryColor,
              ),
              label: Text(
                'redeem_code'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whiteColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalance(BaseState<num> state) {
    final balance = state.data;
    if (balance != null) {
      return Text(
        '${formatOrderPrice(balance)} ${'currency'.tr()}',
        style: TextStyles.boldStyle(
          28,
          color: AppColors.whiteColor,
          weight: FontWeight.w700,
        ),
      );
    }
    if (state.isFailure) {
      return InkWell(
        onTap: cubit.load,
        child: Row(
          children: [
            Flexible(
              child: Text(
                state.errorMessage ?? 'try_again'.tr(),
                style: TextStyles.whiteBold14,
              ),
            ),
            Gap(6.w),
            Icon(
              Icons.refresh_rounded,
              size: 18.r,
              color: AppColors.whiteColor,
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 34.h,
      child: const Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
