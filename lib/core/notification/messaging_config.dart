import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';

import '../helpers/logger.dart';

/// إشعارات الطلبات (المغسلة قبلت أو رفضت، فيه تعديل، المندوب وصل، الدفع...)
/// الإشعار اللي فيه orderId بيحدّث شاشات الطلب المفتوحة أول ما يوصل،
/// ولما يدوس عليه بيفتح تفاصيل الطلب ده، وغير كده بيفتح شاشة الإشعارات
class MessagingConfig {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Safety Tip 1: Add a flag to track if initialization is complete
  static bool _initializationComplete = false;

  /// الأبلكيشن وصل للرئيسية وبقى ينفع نفتح شاشات فوقها
  static bool _appReady = false;

  /// إشعار اتداس عليه قبل ما الأبلكيشن يوصل للرئيسية (فتحه وهو مقفول)
  /// بيستنى لحد البوتوم ناف، عشان السبلاش مايمسحش الشاشة اللي فتحناها
  static Map<String, dynamic>? _pendingTap;

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> initFirebaseMessaging() async {
    if (_initializationComplete) return;

    try {
      await createNotificationChannel();

      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Safety Tip 3: Request permissions with error handling
      final NotificationSettings settings = await messaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          )
          .catchError((e) {
            log('Error requesting notification permissions: $e');
            return const NotificationSettings(
              authorizationStatus: AuthorizationStatus.denied,
              alert: AppleNotificationSetting.disabled,
              announcement: AppleNotificationSetting.disabled,
              badge: AppleNotificationSetting.disabled,
              carPlay: AppleNotificationSetting.disabled,
              criticalAlert: AppleNotificationSetting.disabled,
              sound: AppleNotificationSetting.disabled,
              lockScreen: AppleNotificationSetting.disabled,
              notificationCenter: AppleNotificationSetting.disabled,
              providesAppNotificationSettings:
                  AppleNotificationSetting.disabled,
              showPreviews: AppleShowPreviewSetting.whenAuthenticated,
              timeSensitive: AppleNotificationSetting.disabled,
            );
          });

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // الإشعار اللي بنعرضه واحنا جوه الأبلكيشن بيشيل الـ data في الـ payload
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          log("Notification tapped: ${response.payload}");
          if (response.payload != null) {
            try {
              final data =
                  jsonDecode(response.payload!) as Map<String, dynamic>;
              _handleTap(data);
            } catch (e) {
              log('Error parsing notification payload: $e');
            }
          }
        },
      );

      log('Notification permission: ${settings.authorizationStatus}');

      // التوكن بيتبعت مع اللوجين والتحقق من الرقم، فبنحفظه كل ما يتغير
      // (مفيش endpoint نحدثه بيه من غير لوجين جديد). وعلى iOS لو توكن APNs
      // اتأخر، أول FCM بيوصل من هنا
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        await CacheManager.saveFcmTokenToken(token);
        await _subscribeToTopic();
      });

      // على iOS الـ FCM والتوبيك الاتنين محتاجين توكن APNs يوصل الأول،
      // وده بيوصل بعد طلب الصلاحية بشوية، فبنستناه في الخلفية من غير await
      // عشان تسجيل الـ listeners اللي تحت (زي الإشعار اللي فتح الأبلكيشن) مايتأخرش
      CacheManager.fetchAndSaveFcmToken(
        apnsWait: const Duration(seconds: 15),
      ).then((token) {
        if (token != null) _subscribeToTopic();
      });

      // إشعار وصل والأبلكيشن مفتوح: بنعرضه ونحدث شاشات الطلب على طول
      FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
        log("Foreground message received");
        _notifyOrderChanged(event.data);
        try {
          final RemoteNotification? notification = event.notification;
          if (notification != null) {
            await flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'high_importance_channel',
                  'High Importance Notifications',
                  channelDescription:
                      'This channel is used for important notifications.',
                  icon: '@mipmap/ic_launcher',
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
              payload: jsonEncode(event.data),
            );
          }
        } catch (err) {
          log('Error showing local notification: $err');
        }
      });

      // الأبلكيشن كان مقفول واتفتح من الإشعار
      FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? message,
      ) {
        if (message != null) {
          log('Terminated state message received');
          _handleTap(message.data);
        }
      });

      // الأبلكيشن كان في الخلفية ورجع بالدوس على الإشعار
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('Background state message received');
        _notifyOrderChanged(message.data);
        _handleTap(message.data);
      });

      _initializationComplete = true;
    } catch (e) {
      log('Error initializing Firebase Messaging: $e');
    }
  }

  /// توبيك الإشعارات العامة، وبيتنادى تاني مع تجديد التوكن ومفيش مشكلة في التكرار
  static Future<void> _subscribeToTopic() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('notifications');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  /// بيشتغل والأبلكيشن في الخلفية أو مقفول، والسيستم هو اللي بيعرض الإشعار
  /// فمابنفتحش أي شاشة هنا، الفتح بيحصل لما اليوزر يدوس
  @pragma('vm:entry-point')
  static Future<void> messageHandler(RemoteMessage message) async {
    log('Background message data: ${message.data}');
  }

  /// البوتوم ناف بيناديها أول ما يتبني، ولو فيه إشعار اتداس عليه قبلها بيتفتح دلوقتي
  static void markAppReady() {
    _appReady = true;
    final pending = _pendingTap;
    _pendingTap = null;
    if (pending != null) _handleTap(pending);
  }

  /// لما البوتوم ناف يتقفل (خروج أو انتهاء الجلسة) مانفتحش طلبات فوق اللوجين
  static void markAppNotReady() => _appReady = false;

  /// قبل الرئيسية بيستنى في [_pendingTap]، وبعدها بيفتح على طول
  /// (مش في post frame callback لأنه مابيطلبش فريم، فممكن يفضل مستني لو الشاشة ساكنة)
  static void _handleTap(Map<String, dynamic> data) {
    if (!_appReady) {
      _pendingTap = data;
      return;
    }
    _openFromTap(data);
  }

  /// الإشعار اللي فيه orderId بيفتح تفاصيل الطلب ده، ومعاه رقم الرحلة لو موجود
  /// (إشعار وصول المندوب) عشان تأكيد الاستلام يلاقيه
  static void _openFromTap(Map<String, dynamic> data) {
    try {
      final orderId = _orderIdOf(data);
      logger('Notification tapped for order: $orderId');
      if (orderId == null) {
        AppRouter.router.push(AppRouter.notificationScreen);
        return;
      }
      AppRouter.router.push(
        AppRouter.orderDetails,
        extra: OrderDetailsArgs(
          orderId: orderId,
          deliveryTripId: _intOf(data, const ['deliveryTripId', 'tripId']),
        ),
      );
    } catch (e) {
      log('Error opening notification: $e');
    }
  }

  /// شاشة الطلب المفتوحة (أو الليستة) بتجيبه تاني من السيرفر
  static void _notifyOrderChanged(Map<String, dynamic> data) {
    final orderId = _orderIdOf(data);
    if (orderId != null && getIt.isRegistered<OrderUpdates>()) {
      getIt<OrderUpdates>().notify(orderId);
    }
  }

  /// شكل الـ data مش متوثق، فبنقرا الأسماء المتوقعة زي الإشعارات المحفوظة
  static int? _orderIdOf(Map<String, dynamic> data) =>
      _intOf(data, const ['orderId', 'order_id', 'OrderId']);

  /// قيم الـ data في FCM بتيجي نصوص، فبنحولها لأرقام
  static int? _intOf(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = int.tryParse('${data[key] ?? ''}');
      if (value != null && value > 0) return value;
    }
    return null;
  }

  // Safety Tip 16: Dispose method to clear notifications and reset state
  static void dispose() {
    flutterLocalNotificationsPlugin.cancelAll();
    _initializationComplete = false;
    _pendingTap = null;
  }
}
