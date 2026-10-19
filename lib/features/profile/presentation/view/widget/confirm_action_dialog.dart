import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

/// ديالوج تأكيد بزرارين للإجراءات اللي مينفعش تحصل بالغلط (الخروج وحذف الحساب)
/// بيرجع true لو المستخدم أكد بس (الإلغاء أو القفل من بره الديالوج بيرجعوا false)
Future<bool> showConfirmActionDialog(
  BuildContext context, {
  required String titleKey,
  required String messageKey,
  required String confirmKey,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        titleKey.tr(),
        style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
      ),
      content: Text(
        messageKey.tr(),
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
            style: TextStyles.darkBold14.copyWith(color: AppColors.greyColor2),
          ),
        ),
        TextButton(
          onPressed: () => dialogContext.pop(true),
          child: Text(
            confirmKey.tr(),
            style: TextStyles.darkBold14.copyWith(color: AppColors.redColor2),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
