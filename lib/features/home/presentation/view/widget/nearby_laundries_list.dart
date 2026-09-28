import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/label.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/loading_shimmer.dart';
import 'package:maghsalati/features/home/data/model/nearby_laundry_model.dart';
import 'package:maghsalati/features/home/presentation/view/widget/cleaner_item.dart';
import 'package:maghsalati/features/home/presentation/view/widget/working_hours_dialog.dart';
import 'package:maghsalati/features/home/presentation/view_model/nearby_laundries_cubit.dart';

/// لستة المغاسل الراجعة من الـ cubit، متشاركة بين الهوم وتاب البحث
/// ومابتعملش scroll لوحدها عشان بتتحط جوه SingleChildScrollView
class NearbyLaundriesList extends StatelessWidget {
  /// الكلام اللي بيتعرض لو مفيش ولا مغسلة
  final String emptyText;

  const NearbyLaundriesList({
    super.key,
    this.emptyText = 'no_nearby_laundries',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyLaundriesCubit, BaseState<NearbyLaundryModel>>(
      builder: (context, state) {
        if (state.isInitial || state.isLoading) return _buildLoading();
        if (state.isFailure) {
          return _buildMessage(
            icon: Icons.error_outline,
            text: state.errorMessage ?? 'try_again',
            onRetry: () => context.read<NearbyLaundriesCubit>().getLaundries(),
          );
        }
        if (state.items.isEmpty) {
          return _buildMessage(icon: Icons.search_off, text: emptyText);
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: state.items.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final laundry = state.items[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: CleanerItem(
                laundry: laundry,
                // المقفولة مانقدرش نطلب منها، فبنوريه مواعيدها بدل التفاصيل
                onTap: () => laundry.isAvailableNow
                    ? context.push(AppRouter.laundryDetails, extra: laundry)
                    : WorkingHoursDialog.show(
                        context,
                        laundryId: laundry.id,
                        laundryName: laundry.name,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ShimmerBox(
              height: 200.h,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String text,
    VoidCallback? onRetry,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64.r, color: AppColors.greyColor5),
            Gap(12.h),
            LocalizedLabel(
              text: text,
              style: TextStyles.darkBold16,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: LocalizedLabel(
                  text: 'try_again',
                  style: TextStyles.boldStyle(
                    14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
