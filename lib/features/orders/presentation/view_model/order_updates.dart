import 'dart:async';

import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// بيبلّغ الشاشات إن طلب اتغير
/// - [stream]: رقم الطلب بس والشاشة تجيبه تاني من السيرفر. الإشعارات والأكشنز
///   (التأكيد والرد على التعديل والدفع وكود التسليم) بيبعتوا فيه،
///   والـ orderId بيبقى null لو التغيير مش لطلب معين (زي بعد reconnect)
/// - [orders]: الطلب كله جاي من الـ realtime (OrderUpdated)، فالشاشة بتعرضه
///   على طول من غير ريكوست
/// - [adjustments]: المغسلة بعتت تعديل (AdjustmentCreated) للطلب ده
/// ليستة الطلبات والتفاصيل وشاشة الانتظار بيسمعوا، وهو singleton في get_it
class OrderUpdates {
  final StreamController<int?> _controller = StreamController<int?>.broadcast();
  final StreamController<OrderModel> _orders =
      StreamController<OrderModel>.broadcast();
  final StreamController<int> _adjustments = StreamController<int>.broadcast();

  /// الطلبات اللي شاشتها مفتوحة دلوقتي (تفاصيل أو انتظار)، وممكن نفس الطلب
  /// يبقى مفتوح في شاشتين فوق بعض فبنعد
  final Map<int, int> _watched = {};

  Stream<int?> get stream => _controller.stream;

  Stream<OrderModel> get orders => _orders.stream;

  Stream<int> get adjustments => _adjustments.stream;

  void notify([int? orderId]) => _controller.add(orderId);

  void publish(OrderModel order) => _orders.add(order);

  void adjustmentCreated(int orderId) => _adjustments.add(orderId);

  /// الشاشة بتنادي [watch] في initState و [unwatch] في dispose،
  /// والـ realtime بيعرض تنبيه جوه الأبلكيشن بس لو الطلب مش مفتوح
  void watch(int orderId) => _watched[orderId] = (_watched[orderId] ?? 0) + 1;

  void unwatch(int orderId) {
    final count = (_watched[orderId] ?? 0) - 1;
    if (count > 0) {
      _watched[orderId] = count;
    } else {
      _watched.remove(orderId);
    }
  }

  bool isWatched(int orderId) => _watched.containsKey(orderId);
}
