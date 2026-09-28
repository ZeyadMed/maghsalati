/// بيانات الاستلام اللي بتتبعت مع تأكيد السلة على api/customer/cart/confirm
class ConfirmCartRequest {
  final String deliveryAddress;
  final double latitude;
  final double longitude;
  final String pickupContactName;
  final String pickupContactPhoneNumber;

  const ConfirmCartRequest({
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
    required this.pickupContactName,
    required this.pickupContactPhoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'deliveryAddress': deliveryAddress,
    'latitude': latitude,
    'longitude': longitude,
    'pickupContactName': pickupContactName,
    'pickupContactPhoneNumber': pickupContactPhoneNumber,
  };
}
