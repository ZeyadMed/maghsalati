/// حالة الطلب، الترتيب هنا هو نفس ترتيب خطوات الشريط في الكارت
/// القيم اللي بتيجي من السيرفر بتتحول للـ enum ده بـ [OrderStatusX.fromJson]
enum OrderStatus {
  /// تم الإرسال
  sent,

  /// قيد الغسيل
  washing,

  /// جاهز
  ready,

  /// في الطريق
  onTheWay,

  /// تم التسليم
  delivered,

  /// مكتمل - بتبان في تاب السابقة بس
  completed,

  /// ملغي - بتبان في تاب السابقة بس
  cancelled,
}

extension OrderStatusX on OrderStatus {
  /// مفتاح الترجمة اللي بيتعرض في الشارة فوق الكارت
  String get labelKey => switch (this) {
    OrderStatus.sent => 'status_sent',
    OrderStatus.washing => 'status_washing',
    OrderStatus.ready => 'status_ready',
    OrderStatus.onTheWay => 'status_on_the_way',
    OrderStatus.delivered => 'status_delivered',
    OrderStatus.completed => 'status_completed',
    OrderStatus.cancelled => 'status_cancelled',
  };

  /// الطلب الملغي أو المكتمل خلص خلاص، فبيروح على تاب السابقة
  bool get isFinished =>
      this == OrderStatus.completed || this == OrderStatus.cancelled;

  static OrderStatus fromJson(String? value) => switch (value) {
    'sent' => OrderStatus.sent,
    'washing' => OrderStatus.washing,
    'ready' => OrderStatus.ready,
    'on_the_way' => OrderStatus.onTheWay,
    'delivered' => OrderStatus.delivered,
    'completed' => OrderStatus.completed,
    'cancelled' => OrderStatus.cancelled,
    _ => OrderStatus.sent,
  };
}

/// سطر واحد جوا الطلب (قطعة + كميتها + سعرها + صورتها)
/// الإجمالي بيتحسب من السطور دي فمفيش رقم ثابت متكتوب في الشاشة
class OrderItemModel {
  final int id;
  final String name;
  final int quantity;
  final num price;

  /// ممكن تكون لينك من السيرفر أو إيموجي، والـ UI بيتعامل مع الاتنين
  final String image;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.image = '',
  });

  /// سعر السطر كله (سعر القطعة × الكمية)
  num get total => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: json['price'] as num? ?? 0,
      image: json['image'] as String? ?? '',
    );
  }
}

/// الطلب زي ما بيتعرض في شاشة الطلبات وفي شاشة التفاصيل
class OrderModel {
  final int id;

  /// رقم الطلب اللي بيتعرض للمستخدم زي ORD-2041
  final String reference;
  final String laundryName;
  final OrderStatus status;

  /// تاريخ إنشاء الطلب، بيتعرض تحت اسم المغسلة
  final DateTime date;

  /// موعد التسليم المتوقع، بيبان في كروت التاب الحالية بس
  final String? deliveryEta;

  /// سعر التوصيل بينضاف على الإجمالي في آخر شاشة التفاصيل
  final num deliveryPrice;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.reference,
    required this.laundryName,
    required this.status,
    required this.date,
    required this.items,
    this.deliveryEta,
    this.deliveryPrice = 0,
  });

  /// مجموع أسعار القطع من غير التوصيل
  num get itemsTotal => items.fold<num>(0, (sum, item) => sum + item.total);

  /// الإجمالي النهائي بعد ما التوصيل ينضاف
  num get grandTotal => items.isEmpty ? 0 : itemsTotal + deliveryPrice;

  /// عدد القطع كلها، بيتعرض في كروت التاب السابقة
  int get totalPieces => items.fold(0, (sum, item) => sum + item.quantity);

  /// الطلبات اللي لسه شغالة بتروح لتاب الحالية والباقي للسابقة
  bool get isCurrent => !status.isFinished;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      reference: json['reference'] as String? ?? '',
      laundryName: json['laundry_name'] as String? ?? '',
      status: OrderStatusX.fromJson(json['status'] as String?),
      date:
          DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      deliveryEta: json['delivery_eta'] as String?,
      deliveryPrice: json['delivery_price'] as num? ?? 0,
      items: ((json['items'] as List?) ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
