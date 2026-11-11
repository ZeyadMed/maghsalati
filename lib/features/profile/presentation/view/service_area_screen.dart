import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/page_content_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/retry_error_view.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/service_area_map.dart';
import 'package:maghsalati/features/profile/presentation/view_model/page_content_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة نطاق الخدمة زي التطبيق الصيني: هيدر أزرق، والنص الأول من الشاشة
/// خريطة ليبيا ([ServiceAreaMap])، وتحتها النص اللي راجع من
/// [ContentPage.scopeOfService] على خلفية بيضا من غير كارت ولا تاريخ تحديث
/// الخريطة ثابتة في التطبيق فبتظهر على طول، والتحميل والخطأ بيبقوا تحتها بس
class ServiceAreaScreen extends StatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  State<ServiceAreaScreen> createState() => _ServiceAreaScreenState();
}

class _ServiceAreaScreenState extends State<ServiceAreaScreen> {
  final PageContentCubit _cubit = getIt<PageContentCubit>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _cubit.load(ContentPage.scopeOfService);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          ContentPage.scopeOfService.titleKey.tr(),
          style: TextStyles.darkBold18.copyWith(color: AppColors.whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height / 2,
              child: const ServiceAreaMap(),
            ),
            BlocBuilder<PageContentCubit, BaseState<PageContentModel>>(
              bloc: _cubit,
              builder: (context, state) {
                if (state.isFailure) {
                  return Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: RetryErrorView(
                      message: state.errorMessage,
                      onRetry: _load,
                    ),
                  );
                }
                final page = state.data;
                if (page == null) {
                  return Padding(
                    padding: EdgeInsets.only(top: 32.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                  child: HtmlWidget(
                    page.content,
                    textStyle: TextStyles.darkRegular16.copyWith(
                      color: AppColors.darkTextColor,
                      height: 1.8,
                    ),
                    onTapUrl: _openLink,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// اللينكات اللي جوه المحتوى بتفتح في المتصفح
  Future<bool> _openLink(String url) {
    return launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
  }
}
