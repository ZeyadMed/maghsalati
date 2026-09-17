import 'package:maghsalati/features/profile/data/model/user_model.dart';

/// داتا تجريبية للعرض بس لحد ما ال endpoint يجهز
/// مكتوبة بنفس شكل الـ json اللي هييجي من السيرفر وبتتحول بـ fromJson
/// فلما الـ API يتوصل بنمسح الملف ده وخلاص من غير ما يتغير أي widget
abstract final class MockUserData {
  static const Map<String, dynamic> _json = {
    'id': 1,
    'name': 'أحمد محمد',
    'phone': '0911 234 567',
    'email': 'ahmed@example.com',
    'image': null,
  };

  static UserModel get user => UserModel.fromJson(_json);
}
