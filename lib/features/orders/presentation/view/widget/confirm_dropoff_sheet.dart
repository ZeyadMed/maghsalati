import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
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
import 'package:maghsalati/features/orders/presentation/view_model/confirm_dropoff_cubit.dart';

/// شيت تأكيد الاستلام: المندوب لما يوصل بياخد كود من السيرفر ويديه للعميل،
/// والعميل بيكتبه هنا عشان الطلب يبقى "تم التسليم"
/// الكود في خانة واحدة من غير عدد ثابت لأن طوله مش متوثق،
/// زي شيت كود الاستلام في أبلكيشن المغسلة
class ConfirmDropoffSheet extends StatefulWidget {
  final int orderId;

  /// رقم رحلة التسليم لو معروف، ولو null الكيوبت بيدوّر عليه في الإشعارات
  final int? tripId;

  const ConfirmDropoffSheet({super.key, required this.orderId, this.tripId});

  /// بيرجع true لو السيرفر أكد الكود
  static Future<bool> show(
    BuildContext context, {
    required int orderId,
    int? tripId,
  }) async {
    final confirmed = await showOrderSheet<bool>(
      context,
      ConfirmDropoffSheet(orderId: orderId, tripId: tripId),
    );
    return confirmed ?? false;
  }

  @override
  State<ConfirmDropoffSheet> createState() => _ConfirmDropoffSheetState();
}

class _ConfirmDropoffSheetState extends State<ConfirmDropoffSheet> {
  final ConfirmDropoffCubit _cubit = getIt<ConfirmDropoffCubit>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    _cubit.confirm(orderId: widget.orderId, tripId: widget.tripId, otpCode: code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfirmDropoffCubit, BaseState<void>>(
      bloc: _cubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => Navigator.of(context).pop(true),
      builder: (context, state) {
        return OrderSheetFrame(
          icon: Icons.verified_outlined,
          title: 'confirm_receipt'.tr(),
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetErrorText(
                message: state.isFailure ? state.errorMessage : null,
              ),
              SheetButton(
                label: 'confirm_receipt'.tr(),
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'confirm_dropoff_desc'.tr(),
                style: TextStyles.greyColor2Regular14,
              ),
              Gap(16.h),
              _buildCodeField(),
            ],
          ),
        );
      },
    );
  }

  /// أرقام بس ومن الشمال لليمين حتى في العربي، زي خانة كود التحقق
  Widget _buildCodeField() {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: TextField(
        controller: _codeController,
        autofocus: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 8,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyles.darkBold20.copyWith(
          letterSpacing: 8,
          color: AppColors.primaryColor,
        ),
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          counterText: '',
          hintText: '• • • •',
          hintStyle: TextStyles.darkBold20.copyWith(
            color: AppColors.greyColor5,
          ),
          filled: true,
          fillColor: AppColors.secondaryColor,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
