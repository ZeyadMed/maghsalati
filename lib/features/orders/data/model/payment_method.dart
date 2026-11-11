import 'package:flutter/material.dart';

/// طريقة الدفع، نفس enum PaymentMethod في الباك. بتتبعت وبترجع كنص
/// ("Gateway" / "Wallet") مش رقم
enum PaymentMethod {
  /// بوابة الدفع الإلكتروني: السيرفر بيرجع paymentUrl وبيتفتح في WebView
  gateway,

  /// رصيد المحفظة: بيتخصم على طول ومفيش paymentUrl
  wallet,
}

extension PaymentMethodX on PaymentMethod {
  /// القيمة اللي بتتبعت في الـ body
  String get apiValue => switch (this) {
    PaymentMethod.gateway => 'Gateway',
    PaymentMethod.wallet => 'Wallet',
  };

  String get labelKey => switch (this) {
    PaymentMethod.gateway => 'payment_method_online',
    PaymentMethod.wallet => 'payment_method_wallet',
  };

  IconData get icon => switch (this) {
    PaymentMethod.gateway => Icons.credit_card_rounded,
    PaymentMethod.wallet => Icons.account_balance_wallet_rounded,
  };

  /// null لو السيرفر مابعتهاش (طلبات قبل التغيير)
  static PaymentMethod? fromJson(Object? value) {
    return switch ('${value ?? ''}'.toLowerCase()) {
      'gateway' => PaymentMethod.gateway,
      'wallet' => PaymentMethod.wallet,
      _ => null,
    };
  }
}
