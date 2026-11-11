import 'package:get_it/get_it.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';
import 'package:maghsalati/features/orders/presentation/view_model/active_orders_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/add_driver_review_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/add_review_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/adjustment_response_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_details_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';
import 'package:maghsalati/features/orders/presentation/view_model/orders_cubit.dart';
import 'package:maghsalati/features/orders/presentation/view_model/payment_link_cubit.dart';

class OrdersServicesLocator {
  static Future<void> init({required GetIt getIt}) async {
    getIt.registerLazySingleton<OrdersDataSource>(
      () => OrdersDataSourceImpl(getIt()),
    );
    getIt.registerFactory<OrdersCubit>(() => OrdersCubit(getIt()));
    // شريط متابعة الطلب في الرئيسية
    getIt.registerFactory<ActiveOrdersCubit>(() => ActiveOrdersCubit(getIt()));
    // كلهم factory: واحد جديد لكل شاشة أو شيت وبيتقفل معاها
    getIt.registerFactory<OrderDetailsCubit>(() => OrderDetailsCubit(getIt()));
    getIt.registerFactory<AdjustmentResponseCubit>(
      () => AdjustmentResponseCubit(getIt()),
    );
    getIt.registerFactory<PaymentLinkCubit>(() => PaymentLinkCubit(getIt()));
    // الـ data source بتاعه متسجل مع تفاصيل المغسلة لأنه نفس بتاع عرض التقييمات
    getIt.registerFactory<AddReviewCubit>(() => AddReviewCubit(getIt()));
    getIt.registerFactory<AddDriverReviewCubit>(
      () => AddDriverReviewCubit(getIt()),
    );
    // singleton عشان اللي بيبعت (الإشعارات والأكشنز) واللي بيسمع (الشاشات)
    // يبقوا على نفس الـ stream
    getIt.registerLazySingleton<OrderUpdates>(() => OrderUpdates());
  }
}
