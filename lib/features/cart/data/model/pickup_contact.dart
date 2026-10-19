import 'package:maghsalati/core/cache_manager/cache_manager.dart';

/// اللي هيسلّم الهدوم للمندوب: صاحب الحساب افتراضيًا،
/// أو حد تاني بيتكتب للطلب ده بس من غير ما بيانات الحساب تتغير
class PickupContact {
  final String name;

  /// الرقم كامل بكود الدولة (+218911234567) زي ما بيتبعت للسيرفر
  final String phone;

  const PickupContact({required this.name, required this.phone});

  /// صاحب الحساب من الكاش، والرقم بيتحفظ أول ما بيانات الحساب تتجاب
  factory PickupContact.cachedOwner() => PickupContact(
    name: CacheManager.getUserName() ?? '',
    phone: CacheManager.getUserPhone() ?? '',
  );

  bool get hasName => name.trim().isNotEmpty;

  bool get hasPhone => phone.trim().isNotEmpty;

  bool get isComplete => hasName && hasPhone;

  /// الرقم من غير كود ليبيا ولا الصفر اللي في الأول، لأن حقل الرقم
  /// بيحط +218 لوحده (زي ما المستخدم بيكتبه في الحقل)
  String get nationalNumber {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('218') && digits.length > 9) {
      digits = digits.substring(3);
    }
    return digits.replaceFirst(RegExp(r'^0+'), '');
  }

  /// الاسم والرقم الجداد من السيرفر، ولو حاجة فيهم فاضية بنسيب القديمة
  PickupContact merge({required String name, required String phone}) {
    return PickupContact(
      name: name.trim().isNotEmpty ? name : this.name,
      phone: phone.trim().isNotEmpty ? phone : this.phone,
    );
  }
}
