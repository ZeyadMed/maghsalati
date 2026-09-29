abstract interface class Endpoints {
  static const String baseUrl = 'https://lavanderia.runasp.net/';
  static const String updateLocation = '';

  // ****************************** Auth ********************************
  static const String register = 'api/auth/customer/register';

  /// بتاخد { phoneNumber, code, deviceInfo, deviceId } وبترجع التوكنز
  static const String verifyPhone = 'api/auth/customer/verify-phone';

  /// المدن اللي بتتعرض في الدروب داون بتاعة التسجيل،
  /// بترجع list فيها { id, name } والـ id هو اللي بيتبعت في cityId
  static const String cities = 'api/auth/cities';
  static const String verifyOtp = 'verify-otp';
  static const String login = 'api/auth/customer/login';
  static const String forgetPassword = 'forgot/password';
  static const String resetPasssword = 'forgot/reset-password';
  static const String confirmPassword = '';
  static const String resentOtp = 'resend-otp';
  static const String forgetResendOtp = 'forgot/resend-otp';
  static const String forgetVerifyOtp = 'forgot/verify-otp';
  static const String logOut = 'logout';

  /// بناخد منها accessToken جديد لما القديم يقع بـ 401.
  /// بتستقبل { refreshToken, deviceInfo, deviceId } وبترجع الاتنين جداد جوه data.
  static const String refreshToken = 'api/auth/refresh-token';

  /// بتاخد { refreshToken } وبتلغي الجلسة من عند الباك
  static const String logout = 'api/auth/logout';

  // ****************************** Customer ********************************
  /// بتاخد { lat, lng, radiusKm, cityId, search } كلهم اختياري
  /// وبترجع list بالمغاسل القريبة جوه data
  static const String nearbyLaundries = 'api/customer/laundries/nearby';

  /// بترجع أقسام خدمات المغسلة (غسيل الملابس - بدل ...) وجوا كل قسم القطع بأسعارها
  static String laundryServices(int laundryId) =>
      'api/customer/laundries/$laundryId/services';

  /// بترجع { isAvailableNow, workingHours } وكل يوم فيه openTime و closeTime و isClosed
  static String laundryWorkingHours(int laundryId) =>
      'api/customer/laundries/$laundryId/working-hours';

  /// بتاخد PageIndex و PageSize و rating (من 1 لـ 5، اختياري) في الـ query
  /// وبترجع التقييمات جوه data.data ومعاها pageIndex و totalPages
  static String laundryReviews(int laundryId) =>
      'api/customer/laundries/$laundryId/reviews';

  /// POST: بتاخد { laundryServiceItemId, quantity } وبتضيف القطعة لسلة العميل
  /// GET: بترجع السلة { laundryName, items, itemsTotal, pickupFee, dropoffFee, totalPrice }
  /// DELETE: بتمسح السلة كلها
  static const String cart = 'api/customer/cart';

  /// PUT: بتاخد { quantity } وبتعدل كمية القطعة دي في السلة
  /// DELETE: بتشيل القطعة دي من السلة
  static String cartItem(int cartItemId) => 'api/customer/cart/$cartItemId';

  /// POST: بتاخد { deliveryAddress, latitude, longitude, pickupContactName,
  /// pickupContactPhoneNumber } وبتحول السلة لطلب
  static const String confirmCart = 'api/customer/cart/confirm';

  /// GET: بتاخد PageIndex و PageSize في الـ query وبترجع طلبات العميل
  /// جوه data.data ومعاها pageIndex و totalPages
  static const String orders = 'api/customer/orders';

  // ****************************** Notifications ********************************
  /// GET: بتاخد PageIndex و PageSize في الـ query وبترجع الإشعارات
  /// جوه data.data ومعاها pageIndex و totalPages
  /// DELETE: بتمسح كل الإشعارات
  static const String notifications = 'api/customer/notifications';

  /// DELETE: بتمسح الإشعار ده بس
  static String notification(int notificationId) =>
      'api/customer/notifications/$notificationId';

  /// PUT: بتعلم الإشعار ده كمقروء
  static String readNotification(int notificationId) =>
      'api/customer/notifications/$notificationId/read';

  /// PUT: بتعلم كل الإشعارات كمقروءة
  static const String readAllNotifications =
      'api/customer/notifications/read-all';

  /// اند بوينتس مفتوحة بتتنادى قبل ما يبقى فيه جلسة، فمابنحطش عليها توكن
  /// والـ 401 منها معناه بيانات غلط مش جلسة منتهية
  static bool isPublicAuth(String path) {
    return path.contains(login) ||
        path.contains(verifyPhone) ||
        path.contains(register) ||
        path.contains(cities);
  }
}
