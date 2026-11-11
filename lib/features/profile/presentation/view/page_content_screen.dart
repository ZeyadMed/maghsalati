import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/profile/data/model/page_content_model.dart';
import 'package:maghsalati/features/profile/presentation/view/widget/retry_error_view.dart';
import 'package:maghsalati/features/profile/presentation/view_model/page_content_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة صفحة محتوى زي سياسة الخصوصية أو مقدم الخدمة
/// المحتوى HTML جاي من اند بوينت [page]، وبيتعرض في كارت واحد وتحته تاريخ آخر تحديث
/// نطاق الخدمة بيفتح ServiceAreaScreen بدلها (الراوتر هو اللي بيختار)
class PageContentScreen extends StatefulWidget {
  final ContentPage page;

  const PageContentScreen({super.key, required this.page});

  @override
  State<PageContentScreen> createState() => _PageContentScreenState();
}

class _PageContentScreenState extends State<PageContentScreen> {
  final PageContentCubit _cubit = getIt<PageContentCubit>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _cubit.load(widget.page);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.page.titleKey,
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      body: BlocBuilder<PageContentCubit, BaseState<PageContentModel>>(
        bloc: _cubit,
        builder: (context, state) {
          final page = state.data;
          if (state.isFailure) {
            return RetryErrorView(message: state.errorMessage, onRetry: _load);
          }
          if (page == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          return _buildContent(page);
        },
      ),
    );
  }

  Widget _buildContent(PageContentModel page) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: HtmlWidget(
              page.content,
              textStyle: TextStyles.darkRegular14.copyWith(
                color: AppColors.greyColor2,
                height: 1.7,
              ),
              onTapUrl: _openLink,
            ),
          ),
          if (page.updatedAt != null) ...[
            SizedBox(height: 12.h),
            Text(
              '${'last_updated'.tr()} ${DateFormat('d MMMM yyyy', context.locale.toString()).format(page.updatedAt!)}',
              style: TextStyles.darkRegular12.copyWith(
                color: AppColors.greyColor4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
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
