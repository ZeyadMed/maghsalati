import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const _accessTokenKey = 'token';
  static const _refreshTokenKey = 'refreshToken';
  static const _fcmToken = 'fcmToken';
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';
  static const _userRoleKey = 'userRole';
  static const _isGuestModeKey = 'isGuestMode';
  static SharedPreferences? _sharedPreferences;

  // Singleton instance
  static final CacheManager _instance = CacheManager._internal();

  factory CacheManager() {
    return _instance;
  }

  CacheManager._internal();

  // Initialize SharedPreferences
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // Getter for sharedPreferences with null check
  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw Exception(
          'SharedPreferences not initialized. Call CacheManager.init() first.');
    }
    return _sharedPreferences!;
  }

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else {
      return await sharedPreferences.setDouble(key, value);
    }
  }

  dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  static Future<bool> saveAddress(
      {required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else {
      return await sharedPreferences.setDouble(key, value);
    }
  }

  static dynamic getAdderess({required String key}) {
    return sharedPreferences.get(key);
  }

  static Future<bool> removeAddress({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  /// على iOS الـ FCM مابيتعملش غير بعد ما توكن APNs يوصل من أبل، وده بيوصل
  /// بعد طلب الصلاحية بشوية، فبنستناه لحد [apnsWait] بدل ما getToken
  /// يرمي apns-token-not-set. ولو ماوصلش، onTokenRefresh بيحفظه لما يوصل
  static Future<String?> fetchAndSaveFcmToken({
    Duration apnsWait = const Duration(seconds: 5),
  }) async {
    try {
      if (!await waitForApnsToken(apnsWait)) {
        log('APNs token not available yet, FCM token will come via refresh');
        return null;
      }
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await saveFcmTokenToken(fcmToken);
        log('FCM token fetched and saved');
        return fcmToken;
      } else {
        log('Failed to fetch FCM Token: Token is null');
        return null;
      }
    } catch (e) {
      log('Error fetching FCM Token: $e');
      return null;
    }
  }

  static Future<void> saveAccessToken(String token) async {
    await sharedPreferences.setString(_accessTokenKey, token);
    log('Access token saved');
  }

  static Future<void> delAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    log('token deleted');
  }

  static Future<void> saveRefreshToken(String token) async {
    await sharedPreferences.setString(_refreshTokenKey, token);
    log('Refresh token saved');
  }

  static String? getRefreshTokenSync() {
    return sharedPreferences.getString(_refreshTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final token = sharedPreferences.getString(_refreshTokenKey);
    log('Refresh token retrieved: ${token != null}');
    return token;
  }

  static Future<void> delRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
    log('refresh token deleted');
  }

  /// بنحفظ التوكنين مع بعض بعد اللوجين أو بعد التجديد.
  /// الباك اند بيدوّر الـ refresh token كل مرة فلازم نحفظ الجديد.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  /// بنمسح التوكنين مع بعض عند الخروج أو لما التجديد يفشل
  static Future<void> clearTokens() async {
    await delAccessToken();
    await delRefreshToken();
  }

  /// بنحفظ بيانات المستخدم بعد اللوجين أو تفعيل الرقم، عشان الشاشات
  /// تعرض الاسم من غير ما تبعت ريكوست زيادة
  static Future<void> saveUserData({
    required String userId,
    required String userName,
    required String role,
    String? email,
  }) async {
    if (userId.isNotEmpty) {
      await sharedPreferences.setString(_userIdKey, userId);
    }
    await sharedPreferences.setString(_userNameKey, userName);
    await sharedPreferences.setString(_userRoleKey, role);
    if (email != null && email.isNotEmpty) {
      await sharedPreferences.setString(_userEmailKey, email);
    } else {
      await sharedPreferences.remove(_userEmailKey);
    }
    log('User data saved: $userName ($role)');
  }

  static String? getUserName() => sharedPreferences.getString(_userNameKey);

  static String? getUserEmail() => sharedPreferences.getString(_userEmailKey);

  static String? getUserRole() => sharedPreferences.getString(_userRoleKey);

  /// بنمسح بيانات المستخدم مع التوكنز عند تسجيل الخروج
  static Future<void> clearUserData() async {
    await sharedPreferences.remove(_userIdKey);
    await sharedPreferences.remove(_userNameKey);
    await sharedPreferences.remove(_userEmailKey);
    await sharedPreferences.remove(_userRoleKey);
    log('User data cleared');
  }

  static Future<void> saveFcmTokenToken(String fcmToken) async {
    await sharedPreferences.setString(_fcmToken, fcmToken);
    log('FCM token saved');
  }

  static Future<String?> getAccessToken() async {
    String? token = sharedPreferences.getString(_accessTokenKey);
        return token;
  }

  static Future<String?> getFcmToken() async {
    String? fcmToken = sharedPreferences.getString(_fcmToken);
        return fcmToken;
  }

  /// الـ FCM اللي بيتبعت deviceToken مع اللوجين والتحقق من الرقم عشان السيرفر
  /// يبعت إشعارات الطلبات للجهاز ده، ولو ماتحفظش وقت فتح الأبلكيشن بنجيبه تاني
  /// والتايم أوت عشان اللوجين مايقفش لو Firebase مش قادر يطلّع توكن
  static Future<String> deviceToken() async {
    final saved = await getFcmToken();
    if (saved != null && saved.isNotEmpty) return saved;
    final fetched = await fetchAndSaveFcmToken(
      apnsWait: const Duration(seconds: 2),
    ).timeout(const Duration(seconds: 5), onTimeout: () => null);
    return fetched ?? '';
  }

  /// على أندرويد مفيش APNs فبيرجع true على طول
  /// وعلى iOS بيسأل كل نص ثانية لحد ما التوكن يوصل أو المدة تخلص
  static Future<bool> waitForApnsToken(Duration maxWait) async {
    if (!Platform.isIOS) return true;
    final deadline = DateTime.now().add(maxWait);
    while (true) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) return true;
      if (DateTime.now().isAfter(deadline)) return false;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  static Future<bool> clear() async {
    try {
      await sharedPreferences.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// الباك بيرجع الـ id كـ string فبنحفظه string
  static Future<void> saveUserId(String userId) async {
    await sharedPreferences.setString(_userIdKey, userId);
    log('User ID saved: $userId');
  }

  static Future<String?> getUserId() async {
    final userId = sharedPreferences.getString(_userIdKey);
    log('User ID retrieved: $userId');
    return userId;
  }

  /// Set guest mode flag
  static Future<void> setGuestMode(bool isGuest) async {
    await sharedPreferences.setBool(_isGuestModeKey, isGuest);
    log('Guest mode set to: $isGuest');
  }

  /// Returns whether guest mode is enabled. Defaults to false when not set.
  static Future<bool> isGuestMode() async {
    final val = sharedPreferences.getBool(_isGuestModeKey) ?? false;
    log('Guest mode retrieved: $val');
    return val;
  }

  /// Remove guest mode flag
  static Future<void> clearGuestMode() async {
    await sharedPreferences.remove(_isGuestModeKey);
    log('Guest mode cleared');
  }

  /// Toggle guest mode and return the new value
  static Future<bool> toggleGuestMode() async {
    final current = sharedPreferences.getBool(_isGuestModeKey) ?? false;
    final next = !current;
    await sharedPreferences.setBool(_isGuestModeKey, next);
    log('Guest mode toggled: $next');
    return next;
  }
}
