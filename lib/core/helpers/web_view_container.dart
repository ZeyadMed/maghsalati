import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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

  /// لو قيمته بقت مش null الشاشة بتقفل وترجعها، من غير ما تستنى الصفحة.
  /// تفاصيل الطلب بتستخدمه لما نتيجة الدفع توصل من الـ realtime الأول
  final ValueListenable<String?>? closeSignal;

  const WebViewArgs({
    required this.url,
    this.title = '',
    this.finishUrls = const [],
    this.closeSignal,
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
  bool _confirmingLeave = false;

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
    widget.args.closeSignal?.addListener(_onCloseSignal);
  }

  @override
  void dispose() {
    widget.args.closeSignal?.removeListener(_onCloseSignal);
    super.dispose();
  }

  void _finishIfDone(String url) {
    if (!widget.args.finishUrls.any(url.contains)) return;
    _finish(url);
  }

  void _onCloseSignal() {
    final result = widget.args.closeSignal?.value;
    if (result != null) _finish(result);
  }

  void _finish(String result) {
    if (_finished || !mounted) return;
    _finished = true;
    final navigator = Navigator.of(context);
    // لو ديالوج "هتخرج من الدفع؟" مفتوح بنقفله الأول، وإلا الـ pop هيقفله هو بس
    if (_confirmingLeave) navigator.pop();
    navigator.pop(result);
  }

  /// الخروج قبل ما الصفحة توصل للنهاية بيسأل الأول عشان مايقفلش الدفع بالغلط
  Future<void> _confirmLeave() async {
    _confirmingLeave = true;
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
    _confirmingLeave = false;
    if ((leave ?? false) && mounted && !_finished) Navigator.of(context).pop();
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
