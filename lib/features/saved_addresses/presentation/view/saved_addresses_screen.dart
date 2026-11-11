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
import 'package:maghsalati/core/widget/custom_button.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/retry_error_view.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/saved_address_card.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

/// شاشة عناويني: كل العناوين المحفوظة والافتراضي أولها (الترتيب جاي من السيرفر)
/// ومنها الإضافة والتعديل والحذف وتعيين الافتراضي
class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  /// singleton في get_it فمش بيتعمله close هنا
  final SavedAddressesCubit _cubit = getIt<SavedAddressesCubit>();

  @override
  void initState() {
    super.initState();
    // العناوين ممكن تكون اتغيرت من جهاز تاني، فبنجيبها كل ما الشاشة تفتح
    _cubit.load();
  }

  /// الفورم بيحدث الليستة بنفسه قبل ما يرجع، فمش محتاجين نعمل حاجة بعده
  void _openForm([SavedAddressModel? address]) {
    context.push(AppRouter.addressForm, extra: address);
  }

  Future<void> _setDefault(SavedAddressModel address) async {
    final error = await _cubit.setDefault(address);
    if (!mounted) return;
    if (error != null) {
      context.showErrorMessage(error);
    } else {
      context.showSuccessMessage('default_address_changed'.tr());
    }
  }

  Future<void> _confirmDelete(SavedAddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'delete_address'.tr(),
          style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          // السيرفر بيخلي أحدث عنوان تاني هو الافتراضي، فبنقوله قبل ما يحذف
          address.isDefault
              ? '${'delete_address_confirm'.tr()}\n${'delete_default_address_note'.tr()}'
              : 'delete_address_confirm'.tr(),
          style: TextStyles.darkRegular14.copyWith(
            color: AppColors.greyColor2,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(
              'cancel'.tr(),
              style: TextStyles.darkBold14.copyWith(
                color: AppColors.greyColor2,
              ),
            ),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              'delete'.tr(),
              style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
            ),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false) || !mounted) return;

    // الكيوبت بيجيب الليستة تاني بعد الحذف لأن الافتراضي ممكن يكون اتنقل
    final error = await _cubit.delete(address);
    if (!mounted) return;
    if (error != null) {
      context.showErrorMessage(error);
    } else {
      context.showSuccessMessage('address_deleted'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'saved_addresses',
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: BlocBuilder<SavedAddressesCubit, BaseState<SavedAddressModel>>(
        bloc: _cubit,
        builder: (context, state) => _buildBody(state),
      ),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  Widget _buildBody(BaseState<SavedAddressModel> state) {
    if (state.items.isEmpty) {
      if (state.isLoading || !_cubit.hasLoaded && !state.isFailure) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }
      if (state.isFailure) {
        return RetryErrorView(
          message: state.errorMessage,
          onRetry: _cubit.load,
        );
      }
      return _buildEmptyState();
    }

    return Column(
      children: [
        // التحديث في الخلفية بيبان كخط رفيع، والعناوين بتفضل ظاهرة
        if (state.isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppColors.primaryColor,
            backgroundColor: Colors.transparent,
          ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: _cubit.load,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final address = state.items[index];
                return SavedAddressCard(
                  address: address,
                  isBusy: _cubit.isBusy(address),
                  isDisabled: _cubit.isAnyBusy,
                  onEdit: () => _openForm(address),
                  onDelete: () => _confirmDelete(address),
                  onSetDefault: () => _setDefault(address),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 40.r,
                color: AppColors.primaryColor,
              ),
            ),
            Gap(16.h),
            Text(
              'no_saved_addresses'.tr(),
              style: TextStyles.darkBold16,
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            Text(
              'no_saved_addresses_desc'.tr(),
              style: TextStyles.darkRegular14.copyWith(
                color: AppColors.greyColor2,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// الـ bottomNavigationBar بيدي اللي جواه طول الشاشة كله، والـ Center اللي
  /// جوه CustomButton بيتمدد عليه، فالـ Column بيخلي الزرار على قد محتواه
  Widget _buildAddButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              title: 'add_new_address',
              isIcon: true,
              icon: Icon(
                Icons.add_location_alt_outlined,
                size: 20.r,
                color: AppColors.whiteColor,
              ),
              onPressed: () => _openForm(),
              padding: EdgeInsets.symmetric(vertical: 15.h),
              borderRadius: 14.r,
            ),
          ],
        ),
      ),
    );
  }
}
