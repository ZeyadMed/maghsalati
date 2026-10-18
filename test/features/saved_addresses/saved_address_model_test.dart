import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';

/// نفس مثال الرد اللي في توثيق الباك
final _json = <String, dynamic>{
  'id': 1,
  'title': 'Home',
  'address': 'Nasr City, Cairo, Egypt',
  'latitude': 30.0626,
  'longitude': 31.2497,
  'additionalDetails': 'Building 10, Floor 3, Apartment 5',
  'isDefault': true,
  'createdAt': '2026-10-18T12:40:27Z',
  'updatedAt': '2026-10-18T12:40:27Z',
};

void main() {
  group('SavedAddressModel', () {
    test('بيقرا رد السيرفر', () {
      final address = SavedAddressModel.fromJson(_json);

      expect(address.id, 1);
      expect(address.address, 'Nasr City, Cairo, Egypt');
      expect(address.latitude, 30.0626);
      expect(address.longitude, 31.2497);
      expect(address.additionalDetails, 'Building 10, Floor 3, Apartment 5');
      expect(address.hasDetails, isTrue);
      expect(address.isDefault, isTrue);
      expect(address.isHome, isTrue);
      expect(address.updatedAt, DateTime.utc(2026, 10, 18, 12, 40, 27));
    });

    test('الإحداثيات الصحيحة بتيجي int أحياناً', () {
      final address = SavedAddressModel.fromJson({
        ..._json,
        'latitude': 30,
        'longitude': 31,
        'additionalDetails': null,
      });

      expect(address.latitude, 30.0);
      expect(address.longitude, 31.0);
      expect(address.hasDetails, isFalse);
    });

    test('Home و Work بيتعرفوا من غير ما يفرق الحروف الكبيرة', () {
      final work = SavedAddressModel.fromJson({..._json, 'title': ' work '});
      final custom = SavedAddressModel.fromJson({..._json, 'title': 'بيت أمي'});

      expect(work.isWork, isTrue);
      expect(custom.isHome || custom.isWork, isFalse);
      // الاسم الحر بيتعرض زي ما هو
      expect(custom.displayTitle, 'بيت أمي');
    });

    test('تعديل مكان العنوان أو اسمه بيخليه مختلف', () {
      final address = SavedAddressModel.fromJson(_json);
      final moved = SavedAddressModel.fromJson({..._json, 'latitude': 30.1});

      expect(SavedAddressModel.fromJson(_json), address);
      expect(moved == address, isFalse);
    });
  });

  group('SavedAddressRequest', () {
    test('بيشيل المسافات والتفاصيل الفاضية بتتبعت null', () {
      final json = const SavedAddressRequest(
        title: ' Home ',
        address: ' Nasr City ',
        latitude: 30.0626,
        longitude: 31.2497,
        additionalDetails: '   ',
      ).toJson();

      expect(json['title'], 'Home');
      expect(json['address'], 'Nasr City');
      expect(json['additionalDetails'], isNull);
      expect(json['isDefault'], isFalse);
    });

    test('نطاق الإحداثيات زي السيرفر', () {
      expect(SavedAddressRequest.isValidLatitude(90), isTrue);
      expect(SavedAddressRequest.isValidLatitude(-90.0001), isFalse);
      expect(SavedAddressRequest.isValidLongitude(180), isTrue);
      expect(SavedAddressRequest.isValidLongitude(180.5), isFalse);
    });
  });
}
