import 'package:maghsalati/features/orders/data/model/payment_method.dart';

/// بيانات الاستلام وطريقة الدفع اللي بتتبعت مع تأكيد السلة
/// على api/customer/cart/confirm. [savedAddressId] هو المعتمد عند الباك الجديد
/// (بيجيب العنوان ويعيد الحساب بنفسه)، والعنوان والإحداثيات لسه بيتبعتوا للباك القديم
class ConfirmCartRequest {
  final int savedAddressId;

  /// الإجمالي اللي العميل شافه، ولو السيرفر حسب غيره بيرجع 409 من غير ما يعمل طلب
  final num expectedTotal;
  final String deliveryAddress;
  final double latitude;
  final double longitude;
  final String pickupContactName;
  final String pickupContactPhoneNumber;
  final PaymentMethod paymentMethod;

  const ConfirmCartRequest({
    required this.savedAddressId,
    required this.expectedTotal,
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
    required this.pickupContactName,
    required this.pickupContactPhoneNumber,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'savedAddressId': savedAddressId,
    'expectedTotal': expectedTotal,
    'deliveryAddress': deliveryAddress,
    'latitude': latitude,
    'longitude': longitude,
    'pickupContactName': pickupContactName,
    'pickupContactPhoneNumber': pickupContactPhoneNumber,
    'paymentMethod': paymentMethod.apiValue,
  };
}
