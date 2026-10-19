import 'dart:io';

/// قيود الباك على صورة البروفايل في PUT api/customer/profile
/// بنفحصها قبل الرفع عشان المستخدم يعرف السبب على طول بدل ما الطلب يترفض
abstract final class ProfileImageRules {
  static const allowedExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp'};
  static const maxSizeInBytes = 5 * 1024 * 1024;

  /// بترجع مفتاح ترجمة الخطأ، أو null لو الصورة مقبولة
  static String? validate(File file) {
    final name = file.uri.pathSegments.lastOrNull ?? '';
    final dot = name.lastIndexOf('.');
    final extension = dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'image_type_not_supported';
    }
    if (file.lengthSync() > maxSizeInBytes) return 'image_too_large';
    return null;
  }
}
