import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/wallet/data/model/wallet_transaction_model.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/redeem_code_cubit.dart';

/// شيت شحن المحفظة بكود. بيرجع نتيجة الشحن لو نجح (والرصيد المشترك بيكون
/// اتحدث)، و null لو قفل من غير شحن. أخطاء السيرفر (كود غلط أو مستخدم)
/// بتتعرض جوه الشيت زي ما هي
class RedeemCodeSheet extends StatefulWidget {
  const RedeemCodeSheet({super.key});

  static Future<RechargeResultModel?> show(BuildContext context) =>
      showOrderSheet<RechargeResultModel>(context, const RedeemCodeSheet());

  @override
  State<RedeemCodeSheet> createState() => _RedeemCodeSheetState();
}

class _RedeemCodeSheetState extends State<RedeemCodeSheet> {
  final RedeemCodeCubit _cubit = getIt<RedeemCodeCubit>();
  final _controller = TextEditingController();

  /// خطأ قبل الريكوست، زي إن الخانة فاضية
  String? _localError;

  @override
  void dispose() {
    _cubit.close();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    setState(
      () => _localError = code.isEmpty ? 'redeem_code_empty'.tr() : null,
    );
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    _cubit.redeem(code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RedeemCodeCubit, BaseState<RechargeResultModel>>(
      bloc: _cubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => Navigator.of(context).pop(state.data),
      builder: (context, state) => OrderSheetFrame(
        icon: Icons.card_giftcard_rounded,
        title: 'redeem_code_title'.tr(),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetErrorText(
              message:
                  _localError ??
                  (state.isFailure
                      ? state.errorMessage ?? 'try_again'.tr()
                      : null),
            ),
            SheetButton(
              label: 'redeem'.tr(),
              isLoading: state.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('redeem_code_label'.tr(), style: TextStyles.darkBold14),
            Gap(8.h),
            TextField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.center,
              // الكود لاتيني دايمًا حتى والواجهة عربي
              textDirection: TextDirection.ltr,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
                _UpperCaseFormatter(),
              ],
              onSubmitted: (_) => _submit(),
              onChanged: (_) {
                if (_localError != null) setState(() => _localError = null);
              },
              style: TextStyles.darkBold16.copyWith(letterSpacing: 1.5),
              decoration: InputDecoration(
                hintText: 'redeem_code_hint'.tr(),
                hintStyle: TextStyles.darkRegular14.copyWith(
                  color: AppColors.greyColor5,
                  letterSpacing: 1.5,
                ),
                filled: true,
                fillColor: AppColors.secondaryColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
            Gap(10.h),
            Text(
              'redeem_code_note'.tr(),
              style: TextStyles.greyColor2Regular14.copyWith(fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}

/// الكود بيتكتب بحروف كبيرة زي ما هو مطبوع، والسيرفر مش حساس لحالة الأحرف
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
