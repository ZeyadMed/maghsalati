import 'package:maghsalati/core/helpers/json_reader.dart';

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

  /// بانتظار مندوب التوصيل (10) - الطلب جاهز والمندوب رايح المغسلة ياخده
  awaitingDropoffCollection,

  /// فشل الاستلام (11) - المندوب معرفش ياخد الهدوم من العميل،
  /// والمغسلة يا تعيد المحاولة يا تلغي
  pickupFailed,

  /// فشل التوصيل (12) - المندوب معرفش يسلّم ورجّع الهدوم للمغسلة
  deliveryFailed,

  /// ملغية (13) - نهائية، والطلب بيروح على تاب السابقة
  cancelled,
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
    OrderStatus.awaitingDropoffCollection =>
      'status_awaiting_dropoff_collection',
    OrderStatus.pickupFailed => 'status_pickup_failed',
    OrderStatus.deliveryFailed => 'status_delivery_failed',
    OrderStatus.cancelled => 'status_cancelled',
  };

  /// المسلّمة والمرفوضة والملغية خلصوا خلاص، فبيروحوا على تاب السابقة
  bool get isFinished => switch (this) {
    OrderStatus.delivered ||
    OrderStatus.rejected ||
    OrderStatus.cancelled => true,
    _ => false,
  };

  /// الدفع بيتطلب بعد المطابقة، وإعادة الدفع مسموحة من InProgress لحد Delivered
  bool get isPaymentPhase => switch (this) {
    OrderStatus.inProgress ||
    OrderStatus.ready ||
    OrderStatus.awaitingDropoffCollection ||
    OrderStatus.outForDelivery ||
    OrderStatus.deliveryFailed ||
    OrderStatus.delivered => true,
    _ => false,
  };

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
        10 => OrderStatus.awaitingDropoffCollection,
        11 => OrderStatus.pickupFailed,
        12 => OrderStatus.deliveryFailed,
        13 => OrderStatus.cancelled,
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
      'awaitingdropoffcollection' => OrderStatus.awaitingDropoffCollection,
      'pickupfailed' => OrderStatus.pickupFailed,
      'deliveryfailed' => OrderStatus.deliveryFailed,
      'cancelled' || 'canceled' => OrderStatus.cancelled,
      _ => OrderStatus.newOrder,
    };
  }
}

/// حالة الدفع، ماشية لوحدها جنب حالة الطلب ومش بتوقف شغل المغسلة
enum PaymentStatus {
  /// الدفع لسه ماتطلبش، بيتطلب بعد ما المغسلة تطابق القطع
  none,
  pending,
  successful,
  failed,
}

extension PaymentStatusX on PaymentStatus {
  /// مفتاح الترجمة اللي بيتعرض في شارة الدفع، و none مالهاش شارة
  String get labelKey => switch (this) {
    PaymentStatus.none => '',
    PaymentStatus.pending => 'payment_status_pending',
    PaymentStatus.successful => 'payment_status_successful',
    PaymentStatus.failed => 'payment_status_failed',
  };

  /// زي أبلكيشن المغسلة: الاسم بأي حروف، و "paid" معناها ناجح
  static PaymentStatus fromJson(Object? value) =>
      switch ('${value ?? ''}'.toLowerCase()) {
        'successful' || 'success' || 'paid' => PaymentStatus.successful,
        'failed' => PaymentStatus.failed,
        'pending' => PaymentStatus.pending,
        _ => PaymentStatus.none,
      };
}

/// نوع رحلة المندوب: الاستلام من بيت العميل للمغسلة، والتسليم من المغسلة للعميل
enum DeliveryTripType { pickup, dropoff }

/// مين اللي مستني يدخل الكود دلوقتي (awaitingConfirmationBy)
/// رحلة التسليم ليها كودين: الأول للمغسلة وهي بتسلّم المندوب، والتاني للعميل
enum TripConfirmer { laundry, customer }

/// رحلة من رحلات الطلب. العميل محتاج منها رقمها عشان يأكد التسليم بالكود،
/// وبيانات المندوب عشان يعرف مين جاي
class OrderTripModel {
  final int id;
  final DeliveryTripType type;

  /// زي ما السيرفر بيبعتها، بنستخدمها بس عشان نعرف المندوب وصل ولا لأ
  final String status;
  final String driverName;
  final String driverPhone;

  /// null لو مفيش حد مستني كود دلوقتي
  final TripConfirmer? awaitingConfirmationBy;

  /// السيرفر بعت حقول التأكيد (DeliveryTripDto الرسمي)، فـ [awaitingConfirmationBy]
  /// لما يبقى null معناه إن مفيش كود مطلوب، مش إن الحقل مش موجود
  final bool hasConfirmationInfo;

  /// العميل أكد الاستلام بالكود والطلب بقى Delivered
  final bool isConfirmed;

  /// المغسلة سلمت الهدوم للمندوب (في رحلة التسليم)
  final bool isHandedOver;

  const OrderTripModel({
    required this.id,
    required this.type,
    this.status = '',
    this.driverName = '',
    this.driverPhone = '',
    this.awaitingConfirmationBy,
    this.hasConfirmationInfo = false,
    this.isConfirmed = false,
    this.isHandedOver = false,
  });

  bool get hasDriver => driverName.isNotEmpty || driverPhone.isNotEmpty;

  /// المندوب وصل باب العميل وبقى معاه كود التسليم
  bool get hasArrived =>
      awaitingConfirmationBy == TripConfirmer.customer ||
      status.toLowerCase().contains('arriv');

  /// الكود مطلوب من العميل دلوقتي. لو السيرفر مابعتش حقول التأكيد (ريسبونس
  /// قديم) بنفضل على السلوك القديم ونسيب الزرار ظاهر طول التوصيل
  bool get awaitsCustomer => hasConfirmationInfo
      ? awaitingConfirmationBy == TripConfirmer.customer
      : true;

  /// { id, type, status, driverName, driverPhoneNumber } زي أبلكيشن المغسلة
  /// وبيانات المندوب ممكن تيجي جوه "driver" بدل ما تبقى في الرحلة نفسها
  factory OrderTripModel.fromJson(
    Map<String, dynamic> json, {
    required DeliveryTripType type,
  }) {
    final driver = json.pickMap(['driver']) ?? const <String, dynamic>{};
    return OrderTripModel(
      id: json.pickInt(['id', 'tripId', 'deliveryTripId']) ?? 0,
      type: tripTypeOf(json.pick(['type', 'tripType'])) ?? type,
      status: json.pickString(['status', 'tripStatus']),
      driverName: _firstNotEmpty([
        json.pickString(['driverName']),
        driver.pickString(['fullName', 'name']),
      ]),
      driverPhone: _firstNotEmpty([
        json.pickString(['driverPhoneNumber', 'driverPhone']),
        driver.pickString(['phoneNumber', 'phone']),
      ]),
      awaitingConfirmationBy: confirmerOf(json['awaitingConfirmationBy']),
      hasConfirmationInfo:
          json.containsKey('awaitingConfirmationBy') ||
          json.containsKey('isAwaitingConfirmation'),
      isConfirmed: json['isConfirmed'] == true,
      isHandedOver: json['isHandedOver'] == true,
    );
  }

  /// "Laundry" أو "Customer" بالاسم
  static TripConfirmer? confirmerOf(Object? value) =>
      switch ('${value ?? ''}'.toLowerCase()) {
        'customer' => TripConfirmer.customer,
        'laundry' => TripConfirmer.laundry,
        _ => null,
      };

  /// النوع بيتقري من الاسم بس، لأن الأرقام مش متوثقة ومش عارفين بتبدأ من كام
  static DeliveryTripType? tripTypeOf(Object? value) {
    final text = '${value ?? ''}'.toLowerCase();
    if (text.contains('pick')) return DeliveryTripType.pickup;
    if (text.contains('drop') || text.contains('deliver')) {
      return DeliveryTripType.dropoff;
    }
    return null;
  }
}

/// نوع التعديل، نفس enum OrderAdjustmentItemAction في الباك
enum OrderAdjustmentAction {
  /// وصل صنف غير اللي اتطلب
  replace,

  /// وصلت قطعة زيادة مكانتش في الطلب
  add,

  /// صنف اتطلب ومجاش
  remove,
}

/// سطر واحد في تعديل المغسلة
class OrderAdjustmentItemModel {
  final OrderAdjustmentAction action;

  /// الصنف اللي كان في الطلب، فاضي في الإضافة
  final String oldName;
  final int oldQuantity;

  /// الصنف اللي وصل فعلًا، فاضي في الشيل
  final String newName;
  final int newQuantity;

  /// فرق السعر لو السيرفر بعته، بالموجب لو السعر زاد
  final num? priceDifference;

  const OrderAdjustmentItemModel({
    required this.action,
    this.oldName = '',
    this.oldQuantity = 0,
    this.newName = '',
    this.newQuantity = 0,
    this.priceDifference,
  });

  /// الريكوست اللي المغسلة بتبعته { orderItemId, action, newServiceItemId, newQuantity }
  /// بس اللي بيرجع للعميل مش متوثق، فبنقرا الأسماء المتوقعة، والصنف ممكن
  /// ييجي كـ object جوه السطر
  factory OrderAdjustmentItemModel.fromJson(Map<String, dynamic> json) {
    final action = actionOf(json.pick(['action', 'type']));
    final oldItem =
        json.pickMap(['orderItem', 'originalItem', 'oldItem']) ??
        const <String, dynamic>{};
    final newItem =
        json.pickMap(['newServiceItem', 'newItem', 'serviceItem']) ??
        const <String, dynamic>{};
    // الاسم العام بيتحسب للصنف الجديد في الإضافة وللقديم في الشيل والاستبدال
    final genericName = json.pickString(['serviceItemName', 'itemName']);

    return OrderAdjustmentItemModel(
      action: action,
      oldName: _firstNotEmpty([
        json.pickString([
          'oldServiceItemName',
          'originalServiceItemName',
          'orderItemName',
        ]),
        oldItem.pickString(['serviceItemName', 'name']),
        if (action != OrderAdjustmentAction.add) genericName,
      ]),
      oldQuantity:
          json.pickInt(['oldQuantity', 'originalQuantity']) ??
          oldItem.pickInt(['quantity']) ??
          (action == OrderAdjustmentAction.add
              ? 0
              : json.pickInt(['quantity']) ?? 0),
      newName: _firstNotEmpty([
        json.pickString(['newServiceItemName', 'newItemName']),
        newItem.pickString(['serviceItemName', 'name']),
        if (action == OrderAdjustmentAction.add) genericName,
      ]),
      newQuantity: json.pickInt(['newQuantity']) ?? 0,
      priceDifference: json.pickNum([
        'priceDifference',
        'difference',
        'amountDifference',
        'totalDifference',
      ]),
    );
  }

  /// الـ Swagger بيبعت الاسم (Replace / Add / Remove)
  static OrderAdjustmentAction actionOf(Object? value) =>
      switch ('${value ?? ''}'.toLowerCase()) {
        'add' => OrderAdjustmentAction.add,
        'remove' => OrderAdjustmentAction.remove,
        _ => OrderAdjustmentAction.replace,
      };
}

/// التعديل اللي المغسلة بعتته ومستني رد العميل
class OrderAdjustmentModel {
  final int id;
  final List<OrderAdjustmentItemModel> items;

  /// إجمالي الأصناف بعد التعديل، لو السيرفر بعته
  final num? newItemsTotal;

  /// فرق السعر على التعديل كله (OrderAdjustmentDto.priceDifference)
  final num? priceDifference;

  const OrderAdjustmentModel({
    required this.items,
    this.id = 0,
    this.newItemsTotal,
    this.priceDifference,
  });

  /// OrderAdjustmentDto { id, status, priceDifference, createdAt, items }
  /// وهو نفسه اللي بييجي في حدث AdjustmentCreated
  factory OrderAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return OrderAdjustmentModel(
      id: json.pickInt(['id']) ?? 0,
      items: json
          .pickList(['items', 'adjustmentItems', 'lines'])
          .map(OrderAdjustmentItemModel.fromJson)
          .toList(),
      newItemsTotal: json.pickNum([
        'newItemsTotal',
        'itemsTotalAfter',
        'adjustedItemsTotal',
      ]),
      priceDifference: json.pickNum(['priceDifference', 'totalDifference']),
    );
  }

  /// التعديل ممكن ييجي object في "adjustment"، أو ليستة في "adjustments"
  /// (تعديلات كاملة بناخد آخر واحد، أو أسطر على طول)
  static OrderAdjustmentModel? fromOrderJson(Map<String, dynamic> json) {
    var source = json.pickMap([
      'pendingAdjustment',
      'adjustment',
      'currentAdjustment',
      'lastAdjustment',
    ]);
    if (source == null) {
      final list = json.pickList(['adjustments', 'orderAdjustments']);
      if (list.isEmpty) return null;
      source = list.last.containsKey('items') ? list.last : {'items': list};
    }
    return OrderAdjustmentModel.fromJson(source);
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

  /// العميل رفض التعديل على القطعة دي، فهترجعله من غير غسيل وسعرها اتشال
  final bool isReturned;

  /// ممكن تكون لينك من السيرفر أو إيموجي، والـ UI بيتعامل مع الاتنين
  /// الـ API لسه مش بيبعتها فبتفضل فاضية والـ UI بيعرض أيقونة بديلة
  final String image;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.isReturned = false,
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
      isReturned: json['isReturned'] == true,
    );
  }
}

/// الطلب اللي راجع من api/customer/orders (الليستة) ومن api/customer/orders/{id}
/// التفاصيل بترجع حاجات زيادة (الرحلات والتعديل)، فكل الجديد اختياري
class OrderModel {
  final int id;

  /// بيتبعت مع التقييم، و 0 لو السيرفر مابعتهوش
  final int laundryId;
  final String laundryName;
  final OrderStatus status;

  /// تاريخ إنشاء الطلب، بيتعرض تحت اسم المغسلة
  final DateTime date;
  final String deliveryAddress;

  /// اللي هيسلّم الهدوم للمندوب لو مش العميل نفسه
  final String pickupContactName;
  final String pickupContactPhone;

  /// رسوم توصيل الاستلام (المندوب بياخد الهدوم من العميل)
  final num pickupFee;

  /// رسوم توصيل التسليم (المندوب بيرجع الهدوم للعميل)
  final num dropoffFee;

  /// مجموع أسعار القطع من غير التوصيل
  final num itemsTotal;

  /// الإجمالي زي ما السيرفر حسبه، ولو مابعتهوش بنحسبه
  final num? totalPrice;

  final PaymentStatus paymentStatus;

  /// لينك الدفع، بيتعمل بعد المطابقة وبيتجدد مع إعادة الدفع
  final String? paymentUrl;

  /// سبب الرفض لو المغسلة كتبته
  final String rejectionReason;
  final List<OrderItemModel> items;

  /// رحلة الاستلام بتتعمل لما المغسلة تقبل، والتسليم لما الطلب يبقى جاهز
  final OrderTripModel? pickupTrip;
  final OrderTripModel? dropoffTrip;

  /// التعديل اللي مستني رد العميل، بيبقى موجود في AdjustmentPendingApproval
  final OrderAdjustmentModel? adjustment;

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
    this.laundryId = 0,
    this.pickupContactName = '',
    this.pickupContactPhone = '',
    this.totalPrice,
    this.paymentStatus = PaymentStatus.none,
    this.paymentUrl,
    this.rejectionReason = '',
    this.pickupTrip,
    this.dropoffTrip,
    this.adjustment,
  });

  /// رقم الطلب اللي بيتعرض للمستخدم
  String get reference => '#$id';

  /// الإجمالي النهائي من السيرفر، ولو مش موجود: القطع + رسوم الاستلام + التسليم
  num get grandTotal => totalPrice ?? itemsTotal + pickupFee + dropoffFee;

  /// عدد القطع كلها، بيتعرض في كروت التاب السابقة
  int get totalPieces => items.fold(0, (sum, item) => sum + item.quantity);

  /// الطلبات اللي لسه شغالة بتروح لتاب الحالية والباقي للسابقة
  bool get isCurrent => !status.isFinished;

  bool get isPaid => paymentStatus == PaymentStatus.successful;

  /// الدفع اتطلب ولسه ماتمش، وحالة الطلب نفسها مش بتستنى الدفع
  bool get needsPayment => status.isPaymentPhase && !isPaid;

  bool get hasPaymentUrl => paymentUrl != null && paymentUrl!.isNotEmpty;

  /// رقم رحلة التسليم اللي بيتبعت مع كود التسليم، null لو مش معروف
  int? get dropoffTripId => (dropoffTrip?.id ?? 0) > 0 ? dropoffTrip!.id : null;

  /// المندوب وصل والسيرفر قال صراحة إنه مستني كود العميل. مش بنعتمد هنا على
  /// fallback الريسبونس القديم عشان مانطلعش تنبيه "المندوب وصل" غلط
  bool get awaitsDropoffCode =>
      (dropoffTrip?.hasConfirmationInfo ?? false) &&
      dropoffTrip!.awaitingConfirmationBy == TripConfirmer.customer;

  /// نسخة من الطلب بلينك دفع تاني. أحداث الـ realtime ممكن تيجي من غير
  /// لينك، فبنحتفظ باللي كان معانا بدل ما زرار الدفع يختفي
  OrderModel withPaymentUrl(String? url) => OrderModel(
    id: id,
    laundryId: laundryId,
    laundryName: laundryName,
    status: status,
    date: date,
    deliveryAddress: deliveryAddress,
    pickupContactName: pickupContactName,
    pickupContactPhone: pickupContactPhone,
    pickupFee: pickupFee,
    dropoffFee: dropoffFee,
    itemsTotal: itemsTotal,
    totalPrice: totalPrice,
    paymentStatus: paymentStatus,
    paymentUrl: url,
    rejectionReason: rejectionReason,
    items: items,
    pickupTrip: pickupTrip,
    dropoffTrip: dropoffTrip,
    adjustment: adjustment,
  );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final laundry = json.pickMap(['laundry']) ?? const <String, dynamic>{};
    final paymentStatus = json['isPaid'] == true
        ? PaymentStatus.successful
        : PaymentStatusX.fromJson(json['paymentStatus']);

    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      laundryId: json.pickInt(['laundryId']) ?? laundry.pickInt(['id']) ?? 0,
      laundryName: _firstNotEmpty([
        json['laundryName']?.toString() ?? '',
        laundry.pickString(['name']),
      ]),
      status: OrderStatusX.fromJson(json['status']),
      date:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      pickupContactName: json.pickString(['pickupContactName']),
      pickupContactPhone: json.pickString(['pickupContactPhoneNumber']),
      pickupFee: (json['pickupFee'] as num?) ?? 0,
      dropoffFee: (json['dropoffFee'] as num?) ?? 0,
      itemsTotal: (json['itemsTotal'] as num?) ?? 0,
      totalPrice: json['totalPrice'] as num?,
      paymentStatus: paymentStatus,
      paymentUrl: json['paymentUrl']?.toString(),
      rejectionReason: json.pickString(['rejectionReason', 'rejectReason']),
      items: ((json['items'] as List?) ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pickupTrip: _readTrip(json, DeliveryTripType.pickup),
      dropoffTrip: _readTrip(json, DeliveryTripType.dropoff),
      adjustment: OrderAdjustmentModel.fromOrderJson(json),
    );
  }

  /// الشكل الرسمي (OrderDto) فيه "pickupTrip" و "dropoffTrip" (آخر رحلة من كل نوع)
  /// ولو مش موجودين بنقرا الأشكال القديمة: ليستة "deliveryTrips" أو "trips"
  /// كل رحلة فيها "type"، أو "pickupTripId" / "dropoffTripId" بس
  static OrderTripModel? _readTrip(
    Map<String, dynamic> json,
    DeliveryTripType type,
  ) {
    final key = type == DeliveryTripType.pickup ? 'pickup' : 'dropoff';
    final trip = json.pickMap(['${key}Trip']);
    if (trip != null) return OrderTripModel.fromJson(trip, type: type);

    final trips = json.pickList(['deliveryTrips', 'trips']);
    for (final trip in trips) {
      if (OrderTripModel.tripTypeOf(trip.pick(['type', 'tripType'])) == type) {
        return OrderTripModel.fromJson(trip, type: type);
      }
    }
    // لو النوع مش مكتوب بالاسم، الاستلام بيتعمل الأول والتسليم بعده
    final index = type == DeliveryTripType.pickup ? 0 : 1;
    final hasNamedType = trips.any(
      (trip) =>
          OrderTripModel.tripTypeOf(trip.pick(['type', 'tripType'])) != null,
    );
    if (!hasNamedType && trips.length > index) {
      return OrderTripModel.fromJson(trips[index], type: type);
    }

    final tripId = json.pickInt(['${key}TripId']);
    if (tripId != null) return OrderTripModel(id: tripId, type: type);
    return null;
  }
}

/// أول نص مش فاضي، ولو كلهم فاضيين بيرجع فاضي
String _firstNotEmpty(List<String> values) =>
    values.firstWhere((value) => value.isNotEmpty, orElse: () => '');

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
