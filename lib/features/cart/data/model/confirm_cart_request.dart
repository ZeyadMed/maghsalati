import 'package:maghsalati/features/orders/data/model/payment_method.dart';

/// بيانات الاستلام وطريقة الدفع اللي بتتبعت مع تأكيد السلة
/// على api/customer/cart/confirm
class ConfirmCartRequest {
  final String deliveryAddress;
  final double latitude;
  final double longitude;
  final String pickupContactName;
  final String pickupContactPhoneNumber;
  final PaymentMethod paymentMethod;

  const ConfirmCartRequest({
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
    required this.pickupContactName,
    required this.pickupContactPhoneNumber,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'deliveryAddress': deliveryAddress,
    'latitude': latitude,
    'longitude': longitude,
    'pickupContactName': pickupContactName,
    'pickupContactPhoneNumber': pickupContactPhoneNumber,
    'paymentMethod': paymentMethod.apiValue,
  };
}
