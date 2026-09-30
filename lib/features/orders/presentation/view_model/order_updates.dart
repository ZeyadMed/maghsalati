import 'dart:async';

/// بيبلّغ الشاشات إن طلب اتغير عشان تجيبه تاني من السيرفر
/// الإشعارات والأكشنز (التأكيد والرد على التعديل والدفع وكود التسليم) بيبعتوا فيه،
/// وليستة الطلبات والتفاصيل وشاشة الانتظار بيسمعوا
/// singleton في get_it، والـ orderId بيبقى null لو التغيير مش لطلب معين
class OrderUpdates {
  final StreamController<int?> _controller = StreamController<int?>.broadcast();

  Stream<int?> get stream => _controller.stream;

  void notify([int? orderId]) => _controller.add(orderId);
}
