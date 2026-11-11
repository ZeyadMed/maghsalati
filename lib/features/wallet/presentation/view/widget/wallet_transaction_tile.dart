import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/wallet/data/model/wallet_transaction_model.dart';

/// سطر حركة في المحفظة: الإضافة بسهم أخضر والخصم بسهم أحمر، والنوع
/// والوصف والتاريخ، والمبلغ بإشارته. لو مربوطة بطلب بتفتحه
class WalletTransactionTile extends StatelessWidget {
  final WalletTransactionModel transaction;
  final VoidCallback? onOpenOrder;

  const WalletTransactionTile({
    super.key,
    required this.transaction,
    this.onOpenOrder,
  });

  @override
  Widget build(BuildContext context) {
    final credit = transaction.isCredit;
    final color = credit ? AppColors.greenColor : AppColors.redColor2;
    final title = transaction.type.isNotEmpty
        ? transaction.type
        : (credit ? 'wallet_credit' : 'wallet_debit').tr();

    return InkWell(
      onTap: onOpenOrder,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                credit ? Icons.south_west_rounded : Icons.north_east_rounded,
                size: 18.r,
                color: color,
              ),
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyles.darkBold14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transaction.description.isNotEmpty) ...[
                    Gap(2.h),
                    Text(
                      transaction.description,
                      style: TextStyles.darkRegular12.copyWith(
                        color: AppColors.greyColor2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Gap(4.h),
                  Text(
                    [
                      if (transaction.createdAt != null) _date(context),
                      if (transaction.orderId != null)
                        '${'order_number'.tr()}: #${transaction.orderId}',
                    ].join('  •  '),
                    style: TextStyles.darkRegular12.copyWith(
                      color: AppColors.greyColor3,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Gap(8.w),
            Text(
              '${credit ? '+' : '-'}'
              '${formatOrderPrice(transaction.amount.abs())} ${'currency'.tr()}',
              style: TextStyles.darkBold14.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _date(BuildContext context) => DateFormat(
    'd MMM yyyy - h:mm a',
    context.locale.toString(),
  ).format(transaction.createdAt!.toLocal());
}
