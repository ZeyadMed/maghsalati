import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_ready_time.dart';

OrderModel _order(Map<String, dynamic> extra) => OrderModel.fromJson({
  'id': 7,
  'status': 'InProgress',
  'createdAt': '2026-11-12T08:00:00Z',
  ...extra,
});

void main() {
  group('OrderModel preparation time', () {
    test('nothing is shown before the laundry accepts', () {
      final order = _order({'status': 'New'});
      expect(order.preparationDurationMinutes, isNull);
      expect(order.promisedReadyAt, isNull);
      expect(OrderReadyTime.isVisibleFor(order), isFalse);
    });

    test('between accept and receipt the duration is shown, not a timer', () {
      final order = _order({
        'status': 'AwaitingPickup',
        'preparationDurationMinutes': 240,
      });
      expect(order.showsPreparationDuration, isTrue);
      expect(order.isPreparing, isFalse);
    });

    test('after receipt the countdown runs to promisedReadyAt in UTC', () {
      final order = _order({
        'preparationDurationMinutes': 240,
        'laundryReceivedAt': '2026-11-12T10:00:00Z',
        'promisedReadyAt': '2026-11-12T14:00:00Z',
      });
      expect(order.laundryReceivedAt, DateTime.utc(2026, 11, 12, 10));
      expect(order.promisedReadyAt, DateTime.utc(2026, 11, 12, 14));
      expect(order.promisedReadyAt!.isUtc, isTrue);
      expect(order.isPreparing, isTrue);
      expect(order.showsPreparationDuration, isFalse);
    });

    test('a ready time without Z is still read as UTC', () {
      final order = _order({'promisedReadyAt': '2026-11-12T14:00:00'});
      expect(order.promisedReadyAt, DateTime.utc(2026, 11, 12, 14));
    });

    test('the countdown stops once the order is ready', () {
      final order = _order({
        'status': 'Ready',
        'preparationDurationMinutes': 240,
        'promisedReadyAt': '2026-11-12T14:00:00Z',
      });
      expect(OrderReadyTime.isVisibleFor(order), isFalse);
    });

    test('withPaymentUrl keeps the preparation fields', () {
      final order = _order({
        'preparationDurationMinutes': 1440,
        'promisedReadyAt': '2026-11-13T10:00:00Z',
      }).withPaymentUrl('https://pay');
      expect(order.preparationDurationMinutes, 1440);
      expect(order.promisedReadyAt, DateTime.utc(2026, 11, 13, 10));
    });
  });

  test('formatCountdown shows hh:mm:ss under a day', () {
    expect(
      formatCountdown(const Duration(hours: 3, minutes: 5, seconds: 9)),
      '03:05:09',
    );
    expect(formatCountdown(const Duration(minutes: -75)), '01:15:00');
  });
}
