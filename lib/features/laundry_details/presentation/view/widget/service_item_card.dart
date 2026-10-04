import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/widget/count_badge.dart';

/// خانة القطعة في الجريد: صورة وتحتها الاسم والسعر. الخانات لازقة في بعض
/// وبينها خطوط رفيعة زي الديزاين، والدوسة على الخانة بتزود قطعة في السلة
/// والرقم الأحمر فوق الصورة هو عدد اللي اتختار منها
class ServiceItemCard extends StatelessWidget {
  final ServiceItemModel item;

  /// عدد القطع المختارة، صفر يعني مفيش رقم
  final int quantity;
  final VoidCallback onTap;

  /// آخر خانة في الصف مالهاش خط على جنبها لأن الجريد واصل لحرف الشاشة
  final bool showEndBorder;

  const ServiceItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onTap,
    this.showEndBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.borderColor);

    return Material(
      color: AppColors.whiteColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: side,
              end: showEndBorder ? side : BorderSide.none,
            ),
          ),
          padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 10.h),
          child: Column(
            children: [
              Expanded(child: _buildImage()),
              SizedBox(height: 8.h),
              Text(
                item.name,
                style: TextStyles.darkRegular14.copyWith(fontSize: 13.sp),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                _priceLabel(),
                style: TextStyles.boldStyle(14, color: AppColors.redColor2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// الصورة ممكن تكون لينك أو إيموجي جاي من السيرفر، فبنفرق بينهم هنا
  /// والرقم بيتحط في ركن الصورة بـ Stack
  Widget _buildImage() {
    final isEmoji = !item.image.startsWith('http');

    return Stack(
      children: [
        Positioned.fill(
          child: isEmoji
              ? Center(
                  child: Text(
                    item.image.isEmpty ? '👕' : item.image,
                    style: TextStyle(fontSize: 40.sp),
                  ),
                )
              // contain عشان القطعة تبان كلها على الأبيض زي الديزاين
              : FlexibleImage(
                  source: item.image,
                  borderRadius: 0,
                  fit: BoxFit.contain,
                ),
        ),
        if (quantity > 0)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: CountBadge(count: quantity),
          ),
      ],
    );
  }

  /// السعر + العملة الجاية من الترجمة
  /// الرقم الصحيح بيتعرض من غير كسور يعني 15 مش 15.0
  String _priceLabel() {
    final value = item.price % 1 == 0
        ? item.price.toInt().toString()
        : item.price.toString();
    return '$value ${'currency'.tr()}';
  }
}
