import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';

/// خمس نجوم بيختار منهم العميل تقييمه، صفر يعني لسه مااختارش.
/// نفس الشكل في تقييم المغسلة وتقييم المندوب
class RatingStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double? size;

  const RatingStars({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          onPressed: () => onChanged(value),
          icon: Icon(
            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: size ?? 36.r,
            color: AppColors.lightOrangeColor,
          ),
        );
      }),
    );
  }
}
