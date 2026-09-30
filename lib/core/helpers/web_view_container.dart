import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// اللي بيتبعت لـ [WebViewContainer] في state.extra
class WebViewArgs {
  final String url;
  final String title;

  /// أول ما صفحة لينكها فيه واحد من دول تخلص تحميل، الشاشة بتقفل وترجع اللينك
  /// زي صفحة الـ callback بتاعة الدفع
  final List<String> finishUrls;

  const WebViewArgs({
    required this.url,
    this.title = '',
    this.finishUrls = const [],
  });
}

/// صفحة ويب جوه الأبلكيشن، مستخدمة في دفع MyFatoorah
/// بترجع اللينك اللي خلصت عنده (من [WebViewArgs.finishUrls])،
/// و null لو اليوزر خرج قبل ما توصل
class WebViewContainer extends StatefulWidget {
  final WebViewArgs args;

  const WebViewContainer({super.key, required this.args});

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          // صفحة الـ callback لازم تحمّل للآخر مش نوقفها، لأن تحميلها هو
          // اللي بيخلي الباك يسجل حالة الدفع، فبنقفل بعد ما تخلص
          onPageFinished: _finishIfDone,
          // لو صفحة النهاية نفسها وقعت فالريكوست وصل السيرفر خلاص
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) _finishIfDone(error.url ?? '');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.args.url));
  }

  void _finishIfDone(String url) {
    if (_finished || !mounted) return;
    final done = widget.args.finishUrls.any(url.contains);
    if (!done) return;
    _finished = true;
    Navigator.of(context).pop(url);
  }

  /// الخروج قبل ما الصفحة توصل للنهاية بيسأل الأول عشان مايقفلش الدفع بالغلط
  Future<void> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('cancel_payment_title'.tr(), style: TextStyles.darkBold16),
        content: Text(
          'cancel_payment_message'.tr(),
          style: TextStyles.greyColor2Regular14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'continue_payment'.tr(),
              style: TextStyles.greyColor2Regular14,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'leave'.tr(),
              style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
            ),
          ),
        ],
      ),
    );
    if ((leave ?? false) && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: CustomAppBar(
          title: widget.args.title,
          backgroundColor: AppColors.whiteColor,
        ),
        body: Column(
          children: [
            if (_progress < 100)
              LinearProgressIndicator(
                value: _progress / 100,
                minHeight: 2,
                color: AppColors.primaryColor,
                backgroundColor: AppColors.lightGreyColor,
              ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
