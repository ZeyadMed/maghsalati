import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maghsalati/core/common_widget/custom_error_message.dart';
import 'package:url_launcher/url_launcher.dart';

/// بيفتح الاتصال بالرقم، ولو الجهاز مش عارف يفتحه بنعرض رسالة بدل ما الدوسة تضيع
Future<void> callPhone(BuildContext context, String phone) async {
  final launched = await launchUrl(
    Uri.parse('tel:$phone'),
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);

  if (!launched && context.mounted) {
    CustomErrorOverlay.show(context: context, text: 'contact_failed'.tr());
  }
}
