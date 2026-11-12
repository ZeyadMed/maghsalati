import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

void main() {
  group('OrderTripModel driver details', () {
    test('reads the fields the backend added (2026-11-12)', () {
      final trip = OrderTripModel.fromJson({
        'id': 120,
        'driverName': 'محمود سالم',
        'driverPhoneNumber': '+218912345678',
        'driverProfileImageUrl':
            'https://lavanderia.runasp.net/uploads/drivers/15.jpg',
        'vehicleType': 'Car',
        'vehicleMake': 'Kia',
        'vehicleModel': 'Picanto',
        'vehicleYear': 2018,
        'driverAverageRating': 4.8,
        'driverReviewsCount': 23,
        'driverTotalTrips': 120,
        'driverJoinedAt': '2025-03-04T10:00:00Z',
        'driverPlateNumber': '5-12345',
      }, type: DeliveryTripType.pickup);

      expect(
        trip.driverImageUrl,
        'https://lavanderia.runasp.net/uploads/drivers/15.jpg',
      );
      expect(trip.vehicleType, 'Car');
      expect(trip.vehicleDescription, 'Kia Picanto • 2018');
      expect(trip.driverRating, 4.8);
      expect(trip.driverReviewsCount, 23);
      expect(trip.driverTotalTrips, 120);
      expect(trip.driverJoinedAt, DateTime.utc(2025, 3, 4, 10));
      expect(trip.driverPlateNumber, '5-12345');
    });

    test('nullable fields and a trip without a driver', () {
      final trip = OrderTripModel.fromJson({
        'id': 121,
        'driverProfileImageUrl': null,
        'vehicleType': null,
        'vehicleYear': null,
        'driverAverageRating': null,
        'driverReviewsCount': 0,
      }, type: DeliveryTripType.dropoff);

      expect(trip.driverImageUrl, isNull);
      expect(trip.vehicleType, isEmpty);
      expect(trip.vehicleYear, isNull);
      expect(trip.vehicleDescription, isEmpty);
      expect(trip.isNewDriver, isTrue);
    });
  });
}
