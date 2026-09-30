import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

import 'dart:ui' as ui;

import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/internet_connenction/internet_connection_state.dart';
import 'package:maghsalati/core/internet_connenction/internet_connenction_cubit.dart';
import 'package:maghsalati/core/notification/messaging_config.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/theme/theme.dart';
import 'package:maghsalati/firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'navigatorKey-${DateTime.now().millisecondsSinceEpoch}',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة ScreenUtil
  await ScreenUtil.ensureScreenSize();

  // الإشعارات هي اللي بتقول للعميل إن المغسلة ردت أو بعتت تعديل أو إن المندوب وصل
  // ولو Firebase وقع لأي سبب الأبلكيشن بيكمل عادي من غير إشعارات
  final firebaseReady = await _initFirebase();

  await CacheManager.init();
  EasyLocalization.ensureInitialized();
  await DI.getItInit();
  // من غير await عشان طلب صلاحية الإشعارات مايوقفش فتح الأبلكيشن،
  // وهي اللي بتحفظ الـ FCM اللي بيتبعت مع اللوجين
  if (firebaseReady) MessagingConfig.initFirebaseMessaging();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        saveLocale: true,
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    );
  });
}

/// الإشعار اللي بيوصل والأبلكيشن في الخلفية أو مقفول بيعرضه السيستم لوحده،
/// والـ handler ده بس بيسجل إنه وصل
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(MessagingConfig.messageHandler);
    return true;
  } catch (e) {
    log('Firebase init failed: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // حسب تصميمك (iPhone X / 12)
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return Directionality(
          textDirection: context.locale.languageCode == 'ar'
              ? ui.TextDirection.rtl
              : ui.TextDirection.ltr,
          child: BlocProvider(
            create: (context) => InternetCubit(),
            child: BlocBuilder<InternetCubit, InternetState>(
              builder: (context, state) {
                final bool offline = state is InternetOffState;
                return MaterialApp.router(
                  title: 'Maghsalati',
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  theme: AppThemeData.light(context),
                  routerConfig: AppRouter.router,
                  builder: (context, child) {
                    final media = MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling);

                    if (offline) {
                      return MediaQuery(
                        data: media,
                        child: Scaffold(
                          backgroundColor: AppColors.whiteColor,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Lottie.asset(
                                  Assets.assetsIconsLottieJson,
                                  height: 200.h,
                                ),
                              ),
                              Gap(20.h),
                              Center(
                                child: Text(
                                  "noInternet".tr(),
                                  style: TextStyles.darkBold16.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return MediaQuery(data: media, child: child!);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
