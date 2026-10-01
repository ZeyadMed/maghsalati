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
import 'package:maghsalati/features/orders/presentation/view_model/adjustment_response_cubit.dart';

/// شيت مراجعة تعديل المغسلة لما الطلب يبقى AdjustmentPendingApproval
/// كل سطر بنوعه (صنف مختلف - قطعة زيادة - قطعة ناقصة) والإجمالي بعد التعديل،
/// وتحتهم موافقة أو رفض
class AdjustmentReviewSheet extends StatefulWidget {
  final OrderModel order;

  const AdjustmentReviewSheet({super.key, required this.order});

  /// بيرجع true لو وافق و false لو رفض، و null لو قفل الشيت من غير رد
  static Future<bool?> show(BuildContext context, OrderModel order) {
    return showOrderSheet<bool>(context, AdjustmentReviewSheet(order: order));
  }

  @override
  State<AdjustmentReviewSheet> createState() => _AdjustmentReviewSheetState();
}

class _AdjustmentReviewSheetState extends State<AdjustmentReviewSheet> {
  final AdjustmentResponseCubit _cubit = getIt<AdjustmentResponseCubit>();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _approve() => _cubit.respond(orderId: widget.order.id, approve: true);

  /// الرفض ليه نتيجة على الهدوم نفسها، فبنوضحها ونسأل قبل ما نبعت
  Future<void> _reject() async {
    final reject = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'reject_adjustment_title'.tr(),
          style: TextStyles.darkBold16,
        ),
        content: Text(
          'reject_adjustment_message'.tr(),
          style: TextStyles.greyColor2Regular14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr(), style: TextStyles.greyColor2Regular14),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'reject_adjustment'.tr(),
              style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
            ),
          ),
        ],
      ),
    );
    if (reject ?? false) {
      _cubit.respond(orderId: widget.order.id, approve: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdjustmentResponseCubit, BaseState<bool>>(
      bloc: _cubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => Navigator.of(context).pop(state.data),
      builder: (context, state) {
        return OrderSheetFrame(
          icon: Icons.rule_rounded,
          title: 'adjustment_title'.tr(),
          footer: _buildFooter(state),
          child: _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    final adjustment = widget.order.adjustment;
    final items = adjustment?.items ?? const <OrderAdjustmentItemModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('adjustment_intro'.tr(), style: TextStyles.greyColor2Regular14),
        Gap(14.h),
        // لو السيرفر مابعتش تفاصيل التعديل، العميل يقدر يراجع القطع في التفاصيل
        if (items.isEmpty)
          Text(
            'adjustment_no_details'.tr(),
            style: TextStyles.darkRegular14.copyWith(
              color: AppColors.greyColor3,
            ),
          )
        else
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              Gap(10.h),
              Divider(height: 1.h, color: AppColors.lightGreyColor),
              Gap(10.h),
            ],
            _AdjustmentItemRow(item: items[i]),
          ],
        Gap(16.h),
        _buildTotals(_newItemsTotal(adjustment)),
      ],
    );
  }

  /// الـ DTO الرسمي بيبعت فرق السعر بس، فالإجمالي الجديد = الحالي + الفرق
  num? _newItemsTotal(OrderAdjustmentModel? adjustment) {
    if (adjustment == null) return null;
    if (adjustment.newItemsTotal != null) return adjustment.newItemsTotal;
    final difference = adjustment.priceDifference;
    return difference == null ? null : widget.order.itemsTotal + difference;
  }

  /// إجمالي القطع دلوقتي، وبعد التعديل لو السيرفر بعته
  Widget _buildTotals(num? newItemsTotal) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildAmountRow('items_total'.tr(), widget.order.itemsTotal),
          if (newItemsTotal != null) ...[
            Gap(8.h),
            _buildAmountRow(
              'new_items_total'.tr(),
              newItemsTotal,
              highlighted: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, num amount, {bool highlighted = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: highlighted
                ? TextStyles.darkBold14
                : TextStyles.darkRegular14.copyWith(
                    color: AppColors.greyColor2,
                  ),
          ),
        ),
        Text(
          '${formatOrderPrice(amount)} ${'currency'.tr()}',
          style: highlighted
              ? TextStyles.darkBold14.copyWith(color: AppColors.primaryColor)
              : TextStyles.darkBold14,
        ),
      ],
    );
  }

  /// الزرار اللي اتداس بس هو اللي بيلف، والتاني بيتقفل لحد ما الرد يخلص
  Widget _buildFooter(BaseState<bool> state) {
    final approving = state.isLoading && state.data == true;
    final rejecting = state.isLoading && state.data == false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetErrorText(message: state.isFailure ? state.errorMessage : null),
        Row(
          children: [
            Expanded(
              child: SheetButton(
                label: 'reject_adjustment'.tr(),
                filled: false,
                color: AppColors.redColor2,
                isLoading: rejecting,
                onPressed: state.isLoading ? null : _reject,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SheetButton(
                label: 'approve_adjustment'.tr(),
                isLoading: approving,
                onPressed: state.isLoading ? null : _approve,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// سطر تعديل واحد: شارة بنوعه، وتحتها الصنف قبل وبعد، وفرق السعر على الجنب
class _AdjustmentItemRow extends StatelessWidget {
  final OrderAdjustmentItemModel item;

  const _AdjustmentItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildActionBadge(), Gap(6.h), ..._buildLines()],
          ),
        ),
        if (item.priceDifference != null) ...[
          Gap(12.w),
          _buildDifference(item.priceDifference!),
        ],
      ],
    );
  }

  Widget _buildActionBadge() {
    final (labelKey, color) = switch (item.action) {
      OrderAdjustmentAction.replace => (
        'adjustment_replace',
        AppColors.orangeColor,
      ),
      OrderAdjustmentAction.add => ('adjustment_add', AppColors.primaryColor),
      OrderAdjustmentAction.remove => (
        'adjustment_remove',
        AppColors.redColor2,
      ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        labelKey.tr(),
        style: TextStyles.darkBold12.copyWith(color: color),
      ),
    );
  }

  /// الاستبدال بيعرض القديم متشطب والجديد تحته، والزيادة الجديد بس،
  /// والناقص القديم متشطب
  List<Widget> _buildLines() {
    final removedStyle = TextStyles.darkRegular14.copyWith(
      color: AppColors.greyColor3,
      decoration: TextDecoration.lineThrough,
    );
    final addedStyle = TextStyles.darkBold14;

    return [
      if (item.action != OrderAdjustmentAction.add && item.oldName.isNotEmpty)
        Text(_describe(item.oldName, item.oldQuantity), style: removedStyle),
      if (item.action != OrderAdjustmentAction.remove &&
          item.newName.isNotEmpty) ...[
        Gap(2.h),
        Text(_describe(item.newName, item.newQuantity), style: addedStyle),
      ],
    ];
  }

  String _describe(String name, int quantity) =>
      quantity > 0 ? '$name × $quantity' : name;

  /// الزيادة بالأحمر لأنها هتتضاف على الحساب، والنقص بالأخضر
  Widget _buildDifference(num difference) {
    final increased = difference > 0;
    final sign = increased ? '+' : '';
    return Text(
      '$sign${formatOrderPrice(difference)} ${'currency'.tr()}',
      style: TextStyles.darkBold14.copyWith(
        color: increased ? AppColors.redColor2 : AppColors.greenColor,
      ),
    );
  }
}
