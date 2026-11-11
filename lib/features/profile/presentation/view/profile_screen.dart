import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/contact_info_model.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/customer_service_card.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_header.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_list_section.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/profile_wallet_card.dart';
import 'package:maghsalati/features/profile/presentation/view_model/contact_us_cubit.dart';
import 'package:maghsalati/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';

/// شاشة حسابي على شكل التطبيق الصيني: هيدر بصورة باهتة فيه بيانات المستخدم،
/// وتحته رصيد المحفظة، ومجموعات سطور بيضا بعرض الشاشة، و"المزيد"، وسطر
/// الاتصال بخدمة العملاء
/// بيانات المستخدم جاية من api/customer/profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileCubit _profileCubit = getIt<ProfileCubit>();

  /// رقم خدمة العملاء بييجي من نفس اند بوينت شاشة الدعم
  final ContactUsCubit _contactsCubit = getIt<ContactUsCubit>();

  @override
  void initState() {
    super.initState();
    _profileCubit.getProfile();
    _contactsCubit.getContacts();
    // singleton، فالرصيد بيتحدث هنا وفي أي شاشة تانية بتعرضه
    getIt<WalletBalanceCubit>().load();
  }

  @override
  void dispose() {
    _profileCubit.close();
    _contactsCubit.close();
    super.dispose();
  }

  /// بيفتح شاشة تعديل الملف وبيستنى البيانات الجديدة ترجع منها
  /// لو المستخدم حفظ، الهيدر بيتحدث على طول من غير ما نعيد تحميل الشاشة
  /// ولو البيانات لسه ماوصلتش الدوسة مابتعملش حاجة
  Future<void> _openUpdateProfile() async {
    final user = _profileCubit.state.data;
    if (user == null) return;

    final updated = await context.push<UserModel>(
      AppRouter.updateProfileScreen,
      extra: user,
    );

    if (updated != null && mounted) _profileCubit.setUser(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // مكان الـ status bar بلون الشاشة، والصورة بتبدأ من تحته زي التصميم
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<ProfileCubit, BaseState<UserModel>>(
                bloc: _profileCubit,
                builder: (context, state) => ProfileHeader(
                  user: state.data,
                  hasError: state.isFailure,
                  onRetry: _profileCubit.getProfile,
                  onEdit: _openUpdateProfile,
                ),
              ),
              const ProfileWalletCard(),
              SizedBox(height: 12.h),
              _buildMainSection(),
              SizedBox(height: 12.h),
              ProfileListSection(
                children: [
                  ProfileListRow(
                    icon: Icons.pending_rounded,
                    iconColor: AppColors.greyColor4,
                    titleKey: 'more',
                    onTap: () => context.push(AppRouter.moreScreen),
                  ),
                ],
              ),
              _buildCustomerService(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// القايمة الأساسية، وتعديل الملف الشخصي بقى من الهيدر
  /// نطاق الخدمة ومقدم الخدمة بيتفتحوا من اختصارات صفحة المغسلة
  Widget _buildMainSection() {
    return ProfileListSection(
      children: [
        ProfileListRow(
          icon: Icons.location_on_rounded,
          iconColor: AppColors.lightBlueColor,
          titleKey: 'saved_addresses',
          onTap: () => context.push(AppRouter.savedAddresses),
        ),
        ProfileListRow(
          icon: Icons.notifications_rounded,
          iconColor: AppColors.pinkColor,
          titleKey: 'notifications',
          onTap: () => context.push(AppRouter.notificationScreen),
        ),
        ProfileListRow(
          icon: Icons.verified_user_rounded,
          iconColor: AppColors.darkGreenColor,
          titleKey: 'account_settings',
          onTap: () => context.push(AppRouter.accountSettings),
        ),
        ProfileListRow(
          icon: Icons.rate_review_rounded,
          iconColor: AppColors.orangeColor,
          titleKey: 'support_help',
          onTap: () => context.push(AppRouter.contactUsScreen),
        ),
      ],
    );
  }

  /// سطر الاتصال بخدمة العملاء، ولو الرقم لسه بيحمل أو الطلب وقع مابيظهرش
  /// والأرقام كلها موجودة في شاشة الدعم والمساعدة
  Widget _buildCustomerService() {
    return BlocBuilder<ContactUsCubit, BaseState<ContactInfoModel>>(
      bloc: _contactsCubit,
      builder: (context, state) {
        final phone = state.data?.customerServicePhone ?? '';
        if (phone.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: CustomerServiceCard(phoneNumber: phone),
        );
      },
    );
  }

  /// سطر باهت في الآخر مكان اسم الشركة في التصميم
  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Text(
        'all_rights_reserved'.tr(),
        textAlign: TextAlign.center,
        style: TextStyles.boldStyle(
          12,
          color: AppColors.greyColor4,
          weight: FontWeight.w400,
        ),
      ),
    );
  }
}
