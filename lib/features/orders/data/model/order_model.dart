/// حالة الطلب زي الـ enum اللي في الباك (OrderStatus)، بنفس الترتيب
/// القيم اللي بتيجي من السيرفر بتتحول للـ enum ده بـ [OrderStatusX.fromJson]
enum OrderStatus {
  /// جديدة (1) - مستنية المغسلة تقبل أو ترفض
  newOrder,

  /// بانتظار الاستلام (2) - المغسلة قبلت ورحلة الاستلام مفتوحة
  awaitingPickup,

  /// بانتظار المطابقة (3) - الهدوم اتسلمت والمغسلة بتراجع القطع
  atLaundryPendingMatch,

  /// بانتظار موافقة العميل على تعديل (4) - المغسلة لقت اختلاف في القطع
  adjustmentPendingApproval,

  /// قيد التنفيذ (5) - الغسيل شغال، والدفع بيتطلب هنا
  inProgress,

  /// جاهزة (6)
  ready,

  /// قيد التوصيل (7)
  outForDelivery,

  /// تم التسليم (8) - نهائية، والطلب بيروح على تاب السابقة
  delivered,

  /// مرفوضة (9) - نهائية، والطلب بيروح على تاب السابقة
  rejected,
}

extension OrderStatusX on OrderStatus {
  /// مفتاح الترجمة اللي بيتعرض في الشارة فوق الكارت
  String get labelKey => switch (this) {
    OrderStatus.newOrder => 'status_new',
    OrderStatus.awaitingPickup => 'status_awaiting_pickup',
    OrderStatus.atLaundryPendingMatch => 'status_at_laundry_pending_match',
    OrderStatus.adjustmentPendingApproval =>
      'status_adjustment_pending_approval',
    OrderStatus.inProgress => 'status_in_progress',
    OrderStatus.ready => 'status_ready',
    OrderStatus.outForDelivery => 'status_out_for_delivery',
    OrderStatus.delivered => 'status_delivered',
    OrderStatus.rejected => 'status_rejected',
  };

  /// المسلّمة والمرفوضة خلصوا خلاص، فبيروحوا على تاب السابقة
  bool get isFinished =>
      this == OrderStatus.delivered || this == OrderStatus.rejected;

  /// السيرفر ممكن يبعت الحالة كاسم (New / InProgress) أو كرقم (1 / 5)
  /// فبنقرا الاتنين، والمقارنة من غير حروف كبيرة
  /// أي قيمة مش معروفة بتتعرض كجديدة
  static OrderStatus fromJson(Object? value) {
    final number = value is num ? value.toInt() : int.tryParse('$value');
    if (number != null) {
      return switch (number) {
        2 => OrderStatus.awaitingPickup,
        3 => OrderStatus.atLaundryPendingMatch,
        4 => OrderStatus.adjustmentPendingApproval,
        5 => OrderStatus.inProgress,
        6 => OrderStatus.ready,
        7 => OrderStatus.outForDelivery,
        8 => OrderStatus.delivered,
        9 => OrderStatus.rejected,
        _ => OrderStatus.newOrder,
      };
    }
    return switch ((value?.toString() ?? '').toLowerCase()) {
      'awaitingpickup' => OrderStatus.awaitingPickup,
      'atlaundrypendingmatch' => OrderStatus.atLaundryPendingMatch,
      'adjustmentpendingapproval' => OrderStatus.adjustmentPendingApproval,
      'inprogress' => OrderStatus.inProgress,
      'ready' => OrderStatus.ready,
      'outfordelivery' => OrderStatus.outForDelivery,
      'delivered' => OrderStatus.delivered,
      'rejected' => OrderStatus.rejected,
      _ => OrderStatus.newOrder,
    };
  }
}

/// سطر واحد جوا الطلب (قطعة + كميتها + سعرها)
class OrderItemModel {
  final int id;
  final String name;
  final int quantity;
  final num price;

  /// سعر السطر كله جاي من السيرفر (سعر القطعة × الكمية)
  final num total;

  /// ممكن تكون لينك من السيرفر أو إيموجي، والـ UI بيتعامل مع الاتنين
  /// الـ API لسه مش بيبعتها فبتفضل فاضية والـ UI بيعرض أيقونة بديلة
  final String image;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.image = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?) ?? 0;
    final quantity = (json['quantity'] as num?)?.toInt() ?? 0;
    return OrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['serviceItemName']?.toString() ?? '',
      quantity: quantity,
      price: price,
      total: (json['lineTotal'] as num?) ?? price * quantity,
    );
  }
}

/// الطلب اللي راجع من api/customer/orders
/// زي ما بيتعرض في شاشة الطلبات وفي شاشة التفاصيل
class OrderModel {
  final int id;
  final String laundryName;
  final OrderStatus status;

  /// تاريخ إنشاء الطلب، بيتعرض تحت اسم المغسلة
  final DateTime date;
  final String deliveryAddress;

  /// رسوم توصيل الاستلام (المندوب بياخد الهدوم من العميل)
  final num pickupFee;

  /// رسوم توصيل التسليم (المندوب بيرجع الهدوم للعميل)
  final num dropoffFee;

  /// مجموع أسعار القطع من غير التوصيل
  final num itemsTotal;

  /// لينك الدفع لو الطلب لسه مستني الدفع
  final String? paymentUrl;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.laundryName,
    required this.status,
    required this.date,
    required this.deliveryAddress,
    required this.pickupFee,
    required this.dropoffFee,
    required this.itemsTotal,
    required this.items,
    this.paymentUrl,
  });

  /// رقم الطلب اللي بيتعرض للمستخدم
  String get reference => '#$id';

  /// الإجمالي النهائي: القطع + رسوم الاستلام + رسوم التسليم
  num get grandTotal => itemsTotal + pickupFee + dropoffFee;

  /// عدد القطع كلها، بيتعرض في كروت التاب السابقة
  int get totalPieces => items.fold(0, (sum, item) => sum + item.quantity);

  /// الطلبات اللي لسه شغالة بتروح لتاب الحالية والباقي للسابقة
  bool get isCurrent => !status.isFinished;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      laundryName: json['laundryName']?.toString() ?? '',
      status: OrderStatusX.fromJson(json['status']),
      date:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      pickupFee: (json['pickupFee'] as num?) ?? 0,
      dropoffFee: (json['dropoffFee'] as num?) ?? 0,
      itemsTotal: (json['itemsTotal'] as num?) ?? 0,
      paymentUrl: json['paymentUrl']?.toString(),
      items: ((json['items'] as List?) ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// صفحة من الطلبات، الـ API بيرجعها جوه data ومعاها بيانات الصفحات
class OrdersPageModel {
  final int pageIndex;
  final int totalPages;
  final List<OrderModel> orders;

  const OrdersPageModel({
    required this.pageIndex,
    required this.totalPages,
    required this.orders,
  });

  /// مفيش صفحات تانية بعد دي
  bool get isLastPage => pageIndex >= totalPages;

  factory OrdersPageModel.fromJson(Map<String, dynamic> json) {
    return OrdersPageModel(
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      orders: ((json['data'] as List?) ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
