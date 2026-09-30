import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/common_widget/custom_error_message.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/contact_info_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/retry_error_view.dart';
import 'package:maghsalati/features/profile/presentation/view_model/contact_us_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة تواصل معنا: الأرقام والإيميل جايين من api/auth/contacts
/// كل طريقة بتفتح التطبيق بتاعها، واللي بتيجي فاضية مابتظهرش
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final ContactUsCubit _cubit = getIt<ContactUsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getContacts();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'contact_us',
        backgroundColor: AppColors.secondaryColor,
      ),
      body: BlocBuilder<ContactUsCubit, BaseState<ContactInfoModel>>(
        bloc: _cubit,
        builder: (context, state) {
          final contacts = state.data;
          if (state.isFailure) {
            return RetryErrorView(
              message: state.errorMessage,
              onRetry: _cubit.getContacts,
            );
          }
          if (contacts == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          return _buildContent(contacts);
        },
      ),
    );
  }

  Widget _buildContent(ContactInfoModel contacts) {
    final channels = [
      if (contacts.phoneNumber1.isNotEmpty)
        _buildChannelCard(
          icon: Icons.phone_in_talk_outlined,
          color: AppColors.primaryColor,
          titleKey: 'contact_phone',
          value: contacts.phoneNumber1,
          onTap: () => _launch(Uri.parse('tel:${contacts.phoneNumber1}')),
        ),
      if (contacts.phoneNumber2.isNotEmpty)
        _buildChannelCard(
          icon: Icons.phone_outlined,
          color: AppColors.greenColor,
          titleKey: 'contact_phone_alt',
          value: contacts.phoneNumber2,
          onTap: () => _launch(Uri.parse('tel:${contacts.phoneNumber2}')),
        ),
      if (contacts.email.isNotEmpty)
        _buildChannelCard(
          icon: Icons.mail_outline_rounded,
          color: AppColors.orangeColor,
          titleKey: 'contact_email',
          value: contacts.email,
          onTap: () => _launch(Uri.parse('mailto:${contacts.email}')),
        ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          for (int i = 0; i < channels.length; i++) ...[
            SizedBox(height: i == 0 ? 18.h : 12.h),
            channels[i],
          ],
          // SizedBox(height: 22.h),
          // _buildWorkingHours(),
        ],
      ),
    );
  }

  /// كارت فوق فيه عنوان ترحيبي وسطر بيقول إن الدعم جاهز
  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.support_agent_rounded,
                  size: 24.r,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'contact_header_title'.tr(),
                  style: TextStyles.whiteText(17, weight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'contact_header_body'.tr(),
            style: TextStyles.whiteText(13, weight: FontWeight.w300).copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.9),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  /// سطر طريقة تواصل واحدة: أيقونة واسم وتحته القيمة، وبيفتح التطبيق لما يتداس
  Widget _buildChannelCard({
    required IconData icon,
    required Color color,
    required String titleKey,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20.r, color: color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleKey.tr(),
                      style: TextStyles.darkBold14.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    // الرقم والإيميل دايماً بيتعرضوا من الشمال لليمين
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        value,
                        style: TextStyles.darkRegular12.copyWith(
                          color: AppColors.greyColor3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: AppColors.greyColor5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// مواعيد العمل تحت طرق التواصل
  Widget _buildWorkingHours() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'working_hours'.tr(),
                  style: TextStyles.darkBold14.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'working_hours_value'.tr(),
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بيفتح اللينك، ولو الجهاز مش عارف يفتحه بنعرض رسالة بدل ما الدوسة تضيع
  Future<void> _launch(Uri uri) async {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);

    if (!launched && mounted) {
      CustomErrorOverlay.show(context: context, text: 'contact_failed'.tr());
    }
  }
}
