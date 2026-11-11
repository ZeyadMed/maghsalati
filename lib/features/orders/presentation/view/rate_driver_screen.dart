import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/driver_plate_badge.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/rating_stars.dart';
import 'package:maghsalati/features/orders/presentation/view_model/add_driver_review_cubit.dart';

/// شاشة تقييم مندوب رحلة خلصت: بياناته فوق (الاسم ونوع الرحلة واللوحة)،
/// وتحتها النجوم بوصف لكل درجة وتعليق اختياري.
/// بتتبعت على api/customer/driver-reviews بـ { deliveryTripId, rating, comment }
/// وبترجع true لو التقييم اتبعت
class RateDriverScreen extends StatefulWidget {
  final OrderTripModel trip;

  const RateDriverScreen({super.key, required this.trip});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  final AddDriverReviewCubit _cubit = getIt<AddDriverReviewCubit>();
  final _commentController = TextEditingController();

  /// صفر يعني لسه مااختارش، والزرار بيطلب منه يختار الأول
  int _rating = 0;
  bool _showRatingError = false;

  OrderTripModel get _trip => widget.trip;

  @override
  void dispose() {
    _cubit.close();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_rating == 0) {
      setState(() => _showRatingError = true);
      return;
    }
    final comment = _commentController.text.trim();
    _cubit.submit(
      tripId: _trip.id,
      rating: _rating,
      comment: comment.isEmpty ? null : comment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddDriverReviewCubit, BaseState<void>>(
      bloc: _cubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => context.pop(true),
      builder: (context, state) {
        final error = _showRatingError
            ? 'rating_required'.tr()
            : state.isFailure
            ? state.errorMessage
            : null;

        return Scaffold(
          backgroundColor: AppColors.secondaryColor,
          appBar: CustomAppBar(
            title: 'rate_driver',
            backgroundColor: AppColors.secondaryColor,
          ),
          // الزرار جوه الـ body مش bottomNavigationBar عشان يطلع فوق الكيبورد
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDriverCard(),
                      Gap(14.h),
                      _buildRatingCard(),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                  child: Column(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDriverCard() {
    return OrderSectionCard(
      child: Column(
        children: [
          Container(
            width: 76.r,
            height: 76.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delivery_dining_rounded,
              size: 42.r,
              color: AppColors.primaryColor,
            ),
          ),
          Gap(12.h),
          Text(
            _trip.driverName.isNotEmpty ? _trip.driverName : _trip.driverPhone,
            style: TextStyles.darkBold16,
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          Text(
            (_trip.type == DeliveryTripType.pickup
                    ? 'pickup_driver'
                    : 'dropoff_driver')
                .tr(),
            style: TextStyles.greyColor2Regular14,
            textAlign: TextAlign.center,
          ),
          if (_trip.driverPlateNumber.isNotEmpty) ...[
            Gap(10.h),
            DriverPlateBadge(plateNumber: _trip.driverPlateNumber),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return OrderSectionCard(
      child: Column(
        children: [
          Text(
            'rate_driver_question'.tr(),
            style: TextStyles.darkBold16,
            textAlign: TextAlign.center,
          ),
          Gap(12.h),
          RatingStars(
            rating: _rating,
            size: 42.r,
            onChanged: (value) => setState(() {
              _rating = value;
              _showRatingError = false;
            }),
          ),
          Gap(4.h),
          // وصف الدرجة اللي اختارها، وقبل ما يختار بنقوله يدوس على النجوم
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _rating == 0
                  ? 'rating_tap_stars'.tr()
                  : 'rating_label_$_rating'.tr(),
              key: ValueKey(_rating),
              style: _rating == 0
                  ? TextStyles.greyColor2Regular14
                  : TextStyles.darkBold14.copyWith(
                      color: AppColors.orangeColor,
                    ),
            ),
          ),
          Gap(16.h),
          _buildCommentField(),
        ],
      ),
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
        hintText: 'rate_driver_hint'.tr(),
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
