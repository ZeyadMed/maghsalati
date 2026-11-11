import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/common_widget/custom_error_message.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// سطر "اتصل بخدمة العملاء" الأبيض بعرض الشاشة في آخر شاشة حسابي،
/// الكلام في النص والسطر كله بيفتح الاتصال بالرقم الرسمي
class CustomerServiceCard extends StatelessWidget {
  final String phoneNumber;

  const CustomerServiceCard({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      child: InkWell(
        onTap: () => _call(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_rounded,
                size: 20.r,
                color: AppColors.lightBlueColor2,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'call_customer_service'.tr(),
                  style: TextStyles.boldStyle(14, weight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// لو الجهاز مش عارف يفتح الاتصال بنعرض رسالة بدل ما الدوسة تضيع
  Future<void> _call(BuildContext context) async {
    final launched = await launchUrl(
      Uri.parse('tel:$phoneNumber'),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);

    if (!launched && context.mounted) {
      CustomErrorOverlay.show(context: context, text: 'contact_failed'.tr());
    }
  }
}
