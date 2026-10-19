import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/features/cart/data/model/pickup_contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PickupContact', () {
    test('الرقم بيتعرض في الحقل من غير كود ليبيا والصفر', () {
      String national(String phone) =>
          PickupContact(name: 'a', phone: phone).nationalNumber;

      expect(national('+218911234567'), '911234567');
      expect(national('218911234567'), '911234567');
      expect(national('0911234567'), '911234567');
      expect(national('+218 91 123 4567'), '911234567');
      expect(national(''), '');
    });

    test('بيانات الحساب الجديدة مابتمسحش القديمة لو جت فاضية', () {
      const owner = PickupContact(name: 'أحمد', phone: '');

      final merged = owner.merge(name: '', phone: '+218911234567');

      expect(merged.name, 'أحمد');
      expect(merged.phone, '+218911234567');
      expect(merged.isComplete, isTrue);
      expect(owner.isComplete, isFalse);
    });

    test('صاحب الحساب بيتقري من الكاش، والخروج بيمسح الرقم', () async {
      SharedPreferences.setMockInitialValues({'userName': 'أحمد'});
      await CacheManager.init();

      expect(PickupContact.cachedOwner().hasPhone, isFalse);

      await CacheManager.saveUserContact(name: '', phone: '+218911234567');
      final owner = PickupContact.cachedOwner();
      expect(owner.name, 'أحمد');
      expect(owner.phone, '+218911234567');

      await CacheManager.clearUserData();
      expect(PickupContact.cachedOwner().isComplete, isFalse);
    });
  });
}
