import 'package:flutter/material.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// ألوان شارة الحالة فوق الكارت، متجمعة هنا عشان الكروت كلها تاخد منها
/// بدل ما كل كارت يعرّف ألوانه لوحده
abstract final class OrderStatusStyle {
  /// لون الكلام جوا الشارة
  static Color foregroundOf(OrderStatus status) => switch (status) {
    OrderStatus.completed => AppColors.greenColor,
    OrderStatus.cancelled => AppColors.redColor2,
    OrderStatus.delivered => AppColors.greenColor,
    _ => AppColors.orangeColor,
  };

  /// لون خلفية الشارة، نفس لون الكلام بشفافية خفيفة
  static Color backgroundOf(OrderStatus status) =>
      foregroundOf(status).withValues(alpha: 0.12);
}

/// الرقم الصحيح بيتعرض من غير كسور يعني 8 مش 8.0
String formatOrderPrice(num value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
