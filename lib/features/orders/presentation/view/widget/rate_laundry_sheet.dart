import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view_model/add_review_cubit.dart';

/// شيت تقييم المغسلة بعد التسليم: نجوم من 1 لـ 5 وتعليق اختياري
/// بيتبعت على api/customer/reviews بـ { laundryId, rating, comment }
class RateLaundrySheet extends StatefulWidget {
  final int laundryId;
  final String laundryName;

  const RateLaundrySheet({
    super.key,
    required this.laundryId,
    required this.laundryName,
  });

  /// بيرجع true لو التقييم اتبعت
  static Future<bool> show(
    BuildContext context, {
    required int laundryId,
    required String laundryName,
  }) async {
    final submitted = await showOrderSheet<bool>(
      context,
      RateLaundrySheet(laundryId: laundryId, laundryName: laundryName),
    );
    return submitted ?? false;
  }

  @override
  State<RateLaundrySheet> createState() => _RateLaundrySheetState();
}

class _RateLaundrySheetState extends State<RateLaundrySheet> {
  final AddReviewCubit _cubit = getIt<AddReviewCubit>();
  final _commentController = TextEditingController();

  /// صفر يعني لسه مااختارش، والزرار بيطلب منه يختار الأول
  int _rating = 0;
  bool _showRatingError = false;

  @override
  void dispose() {
    _cubit.close();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      setState(() => _showRatingError = true);
      return;
    }
    final comment = _commentController.text.trim();
    _cubit.submit(
      laundryId: widget.laundryId,
      rating: _rating,
      comment: comment.isEmpty ? null : comment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddReviewCubit, BaseState<void>>(
      bloc: _cubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => Navigator.of(context).pop(true),
      builder: (context, state) {
        final error = _showRatingError
            ? 'rating_required'.tr()
            : state.isFailure
            ? state.errorMessage
            : null;
        return OrderSheetFrame(
          icon: Icons.star_outline_rounded,
          title: 'rate_laundry'.tr(),
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetErrorText(message: error),
              SheetButton(
                label: 'submit'.tr(),
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.laundryName,
                style: TextStyles.darkBold16,
                textAlign: TextAlign.center,
              ),
              Gap(4.h),
              Text(
                'rate_laundry_desc'.tr(),
                style: TextStyles.greyColor2Regular14,
                textAlign: TextAlign.center,
              ),
              Gap(16.h),
              _buildStars(),
              Gap(16.h),
              _buildCommentField(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          onPressed: () => setState(() {
            _rating = value;
            _showRatingError = false;
          }),
          icon: Icon(
            value <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 36.r,
            color: AppColors.lightOrangeColor,
          ),
        );
      }),
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      minLines: 3,
      maxLines: 5,
      maxLength: 500,
      style: TextStyles.darkRegular14,
      decoration: InputDecoration(
        hintText: 'rate_laundry_hint'.tr(),
        hintStyle: TextStyles.darkRegular14.copyWith(
          color: AppColors.hintTextColor,
        ),
        filled: true,
        fillColor: AppColors.secondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
