import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/features/laundry_details/data/model/working_hours_model.dart';

Map<String, dynamic> _day(
  String dayOfWeek, {
  String? open = '09:00:00',
  String? close = '22:00:00',
  bool isClosed = false,
}) => {
  'id': 1,
  'dayOfWeek': dayOfWeek,
  'openTime': open,
  'closeTime': close,
  'isClosed': isClosed,
};

void main() {
  test('الميعاد بيطلع بالإنجليزي حتى لو لغة التطبيق عربي', () {
    Intl.defaultLocale = 'ar';
    final day = WorkingDayModel.fromJson(_day('Saturday'));

    expect(day.formattedRange, '9:00 AM to 10:00 PM');
  });

  test('الأيام بتترتب من السبت للجمعة', () {
    final hours = WorkingHoursModel.fromJson({
      'isAvailableNow': true,
      'workingHours': [
        _day('Sunday'),
        _day('Friday', open: null, close: null, isClosed: true),
        _day('Monday'),
        _day('Saturday'),
      ],
    });

    expect(hours.days.map((d) => d.dayKey), [
      'saturday',
      'sunday',
      'monday',
      'friday',
    ]);
    expect(hours.days.last.isOff, isTrue);
  });
}
