import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/wallet/presentation/view/widget/redeem_code_sheet.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';

/// سطر المحفظة تحت هيدر حسابي، مكان كارت المحفظة في التصميم الصيني:
/// الرصيد، وزرار "شحن" برتقاني بيفتح الشحن بكود، والدوسة على السطر بتفتح
/// شاشة المحفظة. الباك فيه الرصيد بس (مفيش كوبونات أو نقاط)، فمفيش غيره
class ProfileWalletCard extends StatelessWidget {
  const ProfileWalletCard({super.key});

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
    return Material(
      color: AppColors.whiteColor,
      child: InkWell(
        onTap: () => context.push(AppRouter.wallet),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 24.r,
                color: AppColors.primaryColor,
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'wallet_balance'.tr(),
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor3,
                      ),
                    ),
                    Gap(2.h),
                    BlocBuilder<WalletBalanceCubit, BaseState<num>>(
                      bloc: getIt<WalletBalanceCubit>(),
                      builder: (context, state) => Text(
                        state.data == null
                            ? (state.isFailure ? '—' : '...')
                            : '${formatOrderPrice(state.data!)} ${'currency'.tr()}',
                        style: TextStyles.darkBold16.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _recharge(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.orangeColor,
                  foregroundColor: AppColors.whiteColor,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  minimumSize: Size(0, 32.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'recharge_wallet'.tr(),
                  style: TextStyles.whiteBold14,
                ),
              ),
              Gap(8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.r,
                color: AppColors.greyColor5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
