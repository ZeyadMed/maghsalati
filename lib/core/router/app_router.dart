import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/helpers/web_view_container.dart';
import 'package:maghsalati/core/router/bottom_nav_app.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/features/auth/change_password/presentation/view/change_password_screen.dart';
import 'package:maghsalati/features/auth/forget_password/presentation/view/forget_password_screen.dart';
import 'package:maghsalati/features/auth/login/presentation/view/login_screen.dart';
import 'package:maghsalati/features/auth/otp/models/otp_args.dart';
import 'package:maghsalati/features/auth/otp/presentation/view/otp_screen.dart';
import 'package:maghsalati/features/auth/register/presentation/view/register_screen.dart';
import 'package:maghsalati/features/home/data/model/nearby_laundry_model.dart';
import 'package:maghsalati/features/home/presentation/view/home_screen.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/laundry_details.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/service_area_screen.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/service_mechanism_screen.dart';
import 'package:maghsalati/features/laundry_details/presentation/view/service_provider_screen.dart';
import 'package:maghsalati/features/notifications/presentation/view/notifications_screen.dart';
import 'package:maghsalati/features/on_boarding/presentation/views/on_boarding_screen.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';
import 'package:maghsalati/features/order_pending/presentation/view/confirm_order.dart';
import 'package:maghsalati/features/order_pending/presentation/view/oreder_pending.dart';
import 'package:maghsalati/features/order_pending/presentation/view/reject_order.dart';
import 'package:maghsalati/features/orders/data/model/order_details_args.dart';
import 'package:maghsalati/features/orders/presentation/view/order_details_screen.dart';
import 'package:maghsalati/features/orders/presentation/view/orders_screen.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/presentation/view/about_us_screen.dart';
import 'package:maghsalati/features/profile/presentation/view/contact_us_screen.dart';
import 'package:maghsalati/features/profile/presentation/view/privacy_policy_screen.dart';
import 'package:maghsalati/features/profile/presentation/view/profile_screen.dart';
import 'package:maghsalati/features/profile/presentation/view/update_profile_screen.dart';
import 'package:maghsalati/features/splash/presentation/view/splash_screen.dart';
import 'package:maghsalati/main.dart';

abstract class AppRouter {
  static const String root = '/';
  static const String webViewContainer = '/webViewContainer';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String forgetPassword = '/forgetPassword';
  static const String verifyOtp = '/verifyOtp';
  static const String changePassword = '/changePassword';
  static const String resetPasswordScreen = '/resetPasswordScreen';
  static const String successScreen = '/successScreen';
  // ************* HOME *************
  static const String initialRoot = '/initialRoot';
  static const String homeScreen = '/HomeScreen';
  static const String laundryDetails = '/laundryDetails';
  static const String orderPending = '/orderPending';
  static const String confirmOrder = '/confirmOrder';
  static const String rejectOrder = '/rejectOrder';

  // ************* PROFILE *************
  static const String orderScreen = '/orderScreen';
  static const String orderDetails = '/orderDetails';
  static const String profileScreen = '/profileScreen';
  static const String contactUsScreen = '/contactUsScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String customerServiceScreen = '/customerServiceScreen';
  static const String aboutUs = '/aboutUs';
  static const String updateProfileScreen = '/updateProfileScreen';
  static const String privacyPolicy = '/privacyPolicy';
  static const String serviceArea = '/serviceArea';
  static const String serviceProvider = '/serviceProvider';
  static const String serviceMechanism = '/serviceMechanism';
  static const String comingSoonScreen = '/CommingSoonScreen';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      // -----------------------------------Splash Screen and OnBoarding--------------------------------
      GoRoute(path: root, builder: (context, state) => const SplashScreen()),

      // صفحة ويب جوه الأبلكيشن (الدفع)، والـ WebViewArgs بتيجي في state.extra
      // والشاشة بترجع اللينك اللي خلصت عنده
      GoRoute(
        path: webViewContainer,
        builder: (context, state) =>
            WebViewContainer(args: state.extra as WebViewArgs),
      ),
      GoRoute(
        path: initialRoot,
        builder: (context, state) => const BottomNavApp(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // AUTHENTICATION ROUTES
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: signUp,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgetPassword,
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      // OtpArgs بيتبعت في state.extra جاي من التسجيل،
      // فيه الرقم اللي بيتبعت مع الكود والـ purpose اللي بيحدد نروح فين بعد التحقق
      GoRoute(
        path: verifyOtp,
        builder: (context, state) {
          final args = state.extra as OtpArgs?;
          return OtpScreen(
            phoneNumber: args?.phoneNumber ?? '',
            purpose: args?.purpose ?? OtpPurpose.register,
          );
        },
      ),
      // الرقم بيتبعت في state.extra جاي من نسيت كلمة المرور بعد ما الكود يتبعت
      GoRoute(
        path: changePassword,
        builder: (context, state) =>
            ChangePasswordScreen(phoneNumber: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),

      // المغسلة اللي اتداس عليها بتيجي في state.extra من لستة المغاسل القريبة
      // ومن غيرها مفيش laundryId نجيب بيه الخدمات فبيرجع للهوم
      GoRoute(
        path: laundryDetails,
        redirect: (context, state) =>
            state.extra is NearbyLaundryModel ? null : homeScreen,
        builder: (context, state) {
          final laundry = state.extra as NearbyLaundryModel;
          return LaundryDetails(
            laundryId: laundry.id,
            image: laundry.imageUrl.isEmpty
                ? Assets.assetsImagesCleaner
                : laundry.imageUrl,
            name: laundry.name,
            rating: laundry.averageRating,
            ratingCount: laundry.reviewsCount,
          );
        },
      ),

      // الطلب بيتبعت في state.extra جاي من شاشة تفاصيل المغسلة
      GoRoute(
        path: orderPending,
        builder: (context, state) =>
            OrederPending(order: state.extra as PendingOrderModel),
      ),

      // بيتفتح تلقائي من شاشة الانتظار ومعاه نفس الطلب
      GoRoute(
        path: confirmOrder,
        builder: (context, state) =>
            ConfirmOrder(order: state.extra as PendingOrderModel),
      ),

      // شاشة الرفض، بتاخد نفس الطلب عشان زرار "حاول مرة أخرى" يبعته تاني
      GoRoute(
        path: rejectOrder,
        builder: (context, state) =>
            RejectOrder(order: state.extra as PendingOrderModel),
      ),

      GoRoute(
        path: orderScreen,
        builder: (context, state) => const OrdersScreen(),
      ),

      // OrderDetailsArgs بتيجي في state.extra من كارت الطلب أو من الإشعار
      // ومن غيرها مفيش رقم طلب نجيبه بيه فبيرجع للرئيسية
      GoRoute(
        path: orderDetails,
        redirect: (context, state) =>
            state.extra is OrderDetailsArgs ? null : initialRoot,
        builder: (context, state) =>
            OrderDetailsScreen(args: state.extra as OrderDetailsArgs),
      ),
      GoRoute(
        path: profileScreen,
        builder: (context, state) => const ProfileScreen(),
      ),

      // بيانات المستخدم بتتبعت في state.extra جاية من شاشة حسابي
      // والشاشة بترجع النسخة المعدلة لما يدوس حفظ
      GoRoute(
        path: updateProfileScreen,
        builder: (context, state) =>
            UpdateProfileScreen(user: state.extra as UserModel),
      ),
      GoRoute(
        path: privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: contactUsScreen,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: aboutUs,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: serviceArea,
        builder: (context, state) => const ServiceAreaScreen(),
      ),
      GoRoute(
        path: serviceProvider,
        builder: (context, state) => const ServiceProviderScreen(),
      ),
      GoRoute(
        path: serviceMechanism,
        builder: (context, state) => const ServiceMechanismScreen(),
      ),
      GoRoute(
        path: notificationScreen,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
