import 'package:maghsalati/core/helpers/json_reader.dart';
import 'package:maghsalati/features/orders/data/model/payment_method.dart';

export 'package:maghsalati/features/orders/data/model/payment_method.dart';

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

  /// بانتظار الدفع (14) - طلب بوابة دفع لسه مادفعش الدفع المبدئي،
  /// ومش ظاهر للمغسلة لحد ما الدفع ينجح
  pendingPayment,
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
    OrderStatus.pendingPayment => 'status_pending_payment',
  };

  /// المسلّمة والمرفوضة والملغية خلصوا خلاص، فبيروحوا على تاب السابقة
  bool get isFinished => switch (this) {
    OrderStatus.delivered ||
    OrderStatus.rejected ||
    OrderStatus.cancelled => true,
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
        14 => OrderStatus.pendingPayment,
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
      'pendingpayment' => OrderStatus.pendingPayment,
      _ => OrderStatus.newOrder,
    };
  }
}

/// حالة آخر محاولة دفع (paymentStatus)، و null في الـ JSON بتبقى none.
/// الطلب مدفوع بالكامل ولا لأ ده من [OrderModel.isPaid] مش من هنا، لأن الدفع
/// المبدئي ممكن يبقى نجح وفرق المطابقة لسه مستحق
enum PaymentStatus {
  /// مفيش محاولة دفع (زي الدفع من المحفظة)
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

/// مراحل الطلب زي ما العميل بيشوفها، بالترتيب. مش نفس حالات الباك:
/// كذا حالة بتتعرض على نفس المرحلة ([OrderModel.currentStage])، واسم المرحلة
/// ممكن يتغير حسب طريقة التسليم ([OrderModel.stageLabelKey])
enum OrderStage {
  /// قيد الانتظار: المغسلة لسه ماقبلتش
  pending,

  /// تم قبول الطلب
  accepted,

  /// بانتظار استلام الملابس من العميل، أو بانتظار تسليمها للمغسلة
  awaitingHandover,

  /// تم استلام الملابس: وصلت المغسلة وبتتراجع
  received,

  /// قيد التنفيذ
  inProgress,

  /// جاهزة للتوصيل أو للاستلام
  ready,

  /// المندوب في الطريق، بس لو التوصيل بمندوب
  onTheWay,

  /// تم التسليم
  delivered,

  /// مكتمل: اتسلم واتدفع
  completed,
}

/// نوع رحلة المندوب: الاستلام من بيت العميل للمغسلة، والتسليم من المغسلة للعميل
enum DeliveryTripType { pickup, dropoff }

/// مين اللي مستني يدخل الكود دلوقتي (awaitingConfirmationBy)
/// رحلة التسليم فيها كود واحد للمغسلة وهي بتسلّم المندوب. كود العميل اتلغى
/// والمندوب هو اللي بيأكد التسليم، و customer فاضلة بس للريسبونس القديم
enum TripConfirmer { laundry, customer }

/// حالة رحلة المندوب زي ما العميل بيشوفها في كارت المندوب.
/// نفس منطق TripStage في أبلكيشن المندوب بس من ناحية العميل
enum DriverTripStage {
  /// الرحلة اتفتحت ولسه محدش اتعيّن عليها
  awaitingDriver,

  /// الاستلام: رايح للعميل ياخد الهدوم. التسليم: استلم من المغسلة ورايح للعميل
  onTheWay,

  /// وصل باب العميل
  arrived,

  /// الاستلام: أخد الهدوم ورايح بيها المغسلة
  toLaundry,

  /// التسليم: رايح المغسلة أو مستني المغسلة تسلّمه الطلب
  atLaundry,

  /// الاستلام: الهدوم وصلت المغسلة. التسليم: الطلب اتسلّم للعميل
  completed,

  /// PickupFailed أو DeliveryFailed
  failed,
  cancelled,
}

extension DriverTripStageX on DriverTripStage {
  /// المندوب لسه شغال على الرحلة، فمكانه بيبان على الخريطة
  bool get isActive => switch (this) {
    DriverTripStage.onTheWay ||
    DriverTripStage.arrived ||
    DriverTripStage.toLaundry ||
    DriverTripStage.atLaundry => true,
    _ => false,
  };
}

/// رحلة من رحلات الطلب. العميل محتاج منها حالتها وبيانات المندوب عشان يعرف
/// مين جاي، ورقمها عشان يقيّم المندوب
class OrderTripModel {
  final int id;
  final DeliveryTripType type;

  /// زي ما السيرفر بيبعتها، بنستخدمها بس عشان نعرف المندوب وصل ولا لأ
  final String status;
  final String driverName;
  final String driverPhone;

  /// null لو مفيش حد مستني كود دلوقتي
  final TripConfirmer? awaitingConfirmationBy;

  /// الرحلة خلصت: المغسلة أكدت الاستلام، أو المندوب أكد التسليم للعميل
  final bool isConfirmed;

  /// المغسلة سلمت الهدوم للمندوب (في رحلة التسليم)
  final bool isHandedOver;

  /// آخر موقع للمندوب، null لو السيرفر مابعتهوش (لسه مش في الـ API)
  final double? driverLatitude;
  final double? driverLongitude;

  /// بيانات المندوب اللي العميل بيشوفها في كارته. لسه مش في الـ API
  /// (طلبناها من الباك باسم driverPlateNumber و driverTotalTrips
  /// و driverAverageRating و driverReviewsCount و driverJoinedAt)
  /// فكل واحدة فاضية أو null لحد ما السيرفر يبعتها، والكارت بيخبيها
  final String driverPlateNumber;

  /// عدد الرحلات اللي المندوب خلصها بنجاح
  final int? driverTotalTrips;

  /// متوسط التقييم من 0 لـ 5
  final double? driverRating;
  final int? driverReviewsCount;

  /// من إمتى المندوب شغال على المنصة
  final DateTime? driverJoinedAt;

  /// العميل قيّم مندوب الرحلة دي (isDriverReviewed)، و null لو السيرفر
  /// مابعتش الحقل، ساعتها الزرار بيفضل ظاهر والسيرفر هو اللي بيرفض التكرار
  final bool? isDriverReviewed;

  const OrderTripModel({
    required this.id,
    required this.type,
    this.status = '',
    this.driverName = '',
    this.driverPhone = '',
    this.awaitingConfirmationBy,
    this.isConfirmed = false,
    this.isHandedOver = false,
    this.driverLatitude,
    this.driverLongitude,
    this.driverPlateNumber = '',
    this.driverTotalTrips,
    this.driverRating,
    this.driverReviewsCount,
    this.driverJoinedAt,
    this.isDriverReviewed,
  });

  bool get hasDriver => driverName.isNotEmpty || driverPhone.isNotEmpty;

  bool get hasDriverLocation =>
      isValidCoordinate(driverLatitude, driverLongitude);

  bool get hasDriverRating =>
      driverRating != null || driverReviewsCount != null;

  /// فيه إحصائية واحدة على الأقل للمندوب (تقييم أو رحلات أو مدة شغل)
  bool get hasDriverStats =>
      hasDriverRating || driverTotalTrips != null || driverJoinedAt != null;

  /// المندوب لسه محدش قيّمه، فبنكتب "جديد" بدل 0.0
  bool get isNewDriver =>
      (driverReviewsCount ?? 0) == 0 && (driverRating ?? 0) == 0;

  /// عدد الشهور الكاملة من ساعة ما المندوب انضم لحد النهارده
  int? get driverMonthsOfService {
    final joined = driverJoinedAt?.toLocal();
    if (joined == null) return null;
    final now = DateTime.now();
    var months = (now.year - joined.year) * 12 + now.month - joined.month;
    if (now.day < joined.day) months--;
    return months < 0 ? 0 : months;
  }

  /// المندوب وصل باب العميل: الرحلة status = "Arrived" بعد arrive،
  /// أو awaitingConfirmationBy = Customer في ريسبونس الباك القديم
  bool get hasArrived =>
      awaitingConfirmationBy == TripConfirmer.customer ||
      status.toLowerCase().contains('arriv');

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
      isConfirmed: json['isConfirmed'] == true,
      isHandedOver: json['isHandedOver'] == true,
      driverLatitude: json
          .pickNum(['driverLatitude', 'currentLatitude'], inside: ['driver'])
          ?.toDouble(),
      driverLongitude: json
          .pickNum(['driverLongitude', 'currentLongitude'], inside: ['driver'])
          ?.toDouble(),
      driverPlateNumber: json
          .pickString(['driverPlateNumber', 'plateNumber'], inside: ['driver'])
          .trim(),
      driverTotalTrips: json.pickInt(
        ['driverTotalTrips', 'totalTrips', 'completedTripsCount'],
        inside: ['driver'],
      ),
      driverRating: json
          .pickNum(['driverAverageRating', 'averageRating'], inside: ['driver'])
          ?.toDouble()
          .clamp(0, 5)
          .toDouble(),
      driverReviewsCount: json.pickInt(
        ['driverReviewsCount', 'reviewsCount'],
        inside: ['driver'],
      ),
      // createdAt بتاع الرحلة نفسها تاريخ الرحلة، فبنقراه من "driver" بس
      driverJoinedAt: DateTime.tryParse(
        '${json['driverJoinedAt'] ?? driver.pick(['joinedAt', 'createdAt']) ?? ''}',
      ),
      isDriverReviewed: switch (json['isDriverReviewed']) {
        final bool reviewed => reviewed,
        _ => null,
      },
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

  /// الخدمة المطلوبة للقطعة (غسيل وكي - كي فقط ...)، فاضية لو السيرفر مابعتهاش
  final String serviceName;
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
    this.serviceName = '',
    this.isReturned = false,
    this.image = '',
  });

  /// الخدمة والصورة مش في الريسبونس لسه، فبنقرا نفس أسماء السلة
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?) ?? 0;
    final quantity = (json['quantity'] as num?)?.toInt() ?? 0;
    return OrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['serviceItemName']?.toString() ?? '',
      serviceName: json.pickString(['serviceName', 'serviceTypeName']),
      quantity: quantity,
      price: price,
      total: (json['lineTotal'] as num?) ?? price * quantity,
      isReturned: json['isReturned'] == true,
      image: json.pickString([
        'serviceItemImageUrl',
        'serviceImageUrl',
        'imageUrl',
      ]),
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

  /// لوجو المغسلة ورقمها وموقعها، فاضيين لو السيرفر مابعتهومش (لسه مش في الـ API)
  final String laundryLogo;
  final String laundryPhone;
  final double? laundryLatitude;
  final double? laundryLongitude;
  final OrderStatus status;

  /// تاريخ إنشاء الطلب، بيتعرض تحت اسم المغسلة
  final DateTime date;

  /// عنوان الاستلام والتوصيل (نفس العنوان للاتنين) وإحداثياته
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;

  /// صاحب الحساب زي ما أبلكيشن المغسلة بيقراه، والشاشة بتكمّل من البروفايل
  final String customerName;
  final String customerPhone;

  /// اللي هيسلّم الهدوم للمندوب لو مش العميل نفسه
  final String pickupContactName;
  final String pickupContactPhone;

  /// ملاحظات وصور الطلب، فاضيين لحد ما السيرفر يبعتهم
  final String notes;
  final List<String> images;

  /// طريقة التسليم: العميل بيودّي الهدوم المغسلة بنفسه بدل المندوب، و/أو
  /// بيستلمها منها بنفسه. الباك لسه مافيهوش الاختيار ده فالاتنين false
  final bool customerDropsOff;
  final bool customerCollects;

  /// رسوم توصيل الاستلام (المندوب بياخد الهدوم من العميل)
  final num pickupFee;

  /// رسوم توصيل التسليم (المندوب بيرجع الهدوم للعميل)
  final num dropoffFee;

  /// مجموع أسعار القطع من غير التوصيل
  final num itemsTotal;

  /// رسوم خدمة المنصة، و 0 لو مفيش (الـ API لسه مابيبعتهاش)
  final num platformFee;

  /// الخصم أو قيمة الكوبون بالموجب، و 0 لو مفيش
  final num discount;

  /// كود الكوبون اللي اتخصم بيه، فاضي لو مفيش
  final String couponCode;

  /// مجموع اللي اتدفع (amountPaid)، null لو السيرفر مابعتهوش
  final num? amountPaid;

  /// المتبقي على العميل (outstandingAmount): الدفع المبدئي لو مادفعش،
  /// أو فرق المطابقة لو السعر زاد. 0 يعني مدفوع بالكامل
  final num? outstandingAmount;

  /// اتدفع بالكامل (isPaid من السيرفر)
  final bool isPaid;

  /// الطريقة اللي العميل اختارها وقت الطلب، null للطلبات القديمة
  final PaymentMethod? paymentMethod;

  /// الإجمالي زي ما السيرفر حسبه، ولو مابعتهوش بنحسبه
  final num? totalPrice;

  final PaymentStatus paymentStatus;

  /// لينك بوابة الدفع، null لو الدفع من المحفظة. بيتجدد مع كل /pay بالبوابة
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
    this.laundryLogo = '',
    this.laundryPhone = '',
    this.laundryLatitude,
    this.laundryLongitude,
    this.latitude,
    this.longitude,
    this.customerName = '',
    this.customerPhone = '',
    this.pickupContactName = '',
    this.pickupContactPhone = '',
    this.notes = '',
    this.images = const [],
    this.customerDropsOff = false,
    this.customerCollects = false,
    this.platformFee = 0,
    this.discount = 0,
    this.couponCode = '',
    this.amountPaid,
    this.outstandingAmount,
    this.isPaid = false,
    this.paymentMethod,
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

  /// الإجمالي النهائي من السيرفر، ولو مش موجود:
  /// القطع + رسوم الاستلام + التسليم + رسوم المنصة - الخصم
  num get grandTotal =>
      totalPrice ??
      itemsTotal + pickupFee + dropoffFee + platformFee - discount;

  /// الفاتورة بتطلع للطلبات المكتملة بس (اتسلمت للعميل)
  bool get hasInvoice => status == OrderStatus.delivered;

  /// عدد القطع كلها، بيتعرض في كروت التاب السابقة
  int get totalPieces => items.fold(0, (sum, item) => sum + item.quantity);

  /// الطلبات اللي لسه شغالة بتروح لتاب الحالية والباقي للسابقة
  bool get isCurrent => !status.isFinished;

  /// المراحل اللي تنطبق على الطلب: "المندوب في الطريق" بس لو التوصيل بمندوب
  List<OrderStage> get stages => [
    for (final stage in OrderStage.values)
      if (stage != OrderStage.onTheWay || !customerCollects) stage,
  ];

  /// المرحلة اللي الطلب واقف عندها، و null للمرفوض والملغي (مالهمش مراحل).
  /// المطابقة والتعديل بيحصلوا بعد ما الهدوم توصل، والفشل بيفضل على المرحلة
  /// اللي وقف عندها، والمسلّم بيبقى مكتمل لما يتدفع
  OrderStage? get currentStage => switch (status) {
    OrderStatus.newOrder || OrderStatus.pendingPayment => OrderStage.pending,
    OrderStatus.awaitingPickup ||
    OrderStatus.pickupFailed => OrderStage.awaitingHandover,
    OrderStatus.atLaundryPendingMatch ||
    OrderStatus.adjustmentPendingApproval => OrderStage.received,
    OrderStatus.inProgress => OrderStage.inProgress,
    OrderStatus.ready ||
    OrderStatus.awaitingDropoffCollection => OrderStage.ready,
    OrderStatus.outForDelivery || OrderStatus.deliveryFailed =>
      customerCollects ? OrderStage.ready : OrderStage.onTheWay,
    OrderStatus.delivered =>
      isPaid ? OrderStage.completed : OrderStage.delivered,
    OrderStatus.rejected || OrderStatus.cancelled => null,
  };

  /// الطلب وقف عند مرحلته (المندوب معرفش يستلم أو يسلّم)
  bool get isStageFailed =>
      status == OrderStatus.pickupFailed ||
      status == OrderStatus.deliveryFailed;

  /// اسم المرحلة، والمراحل اللي ليها علاقة بطريقة التسليم اسمها بيتغير
  String stageLabelKey(OrderStage stage) => switch (stage) {
    OrderStage.pending => 'stage_pending',
    OrderStage.accepted => 'stage_accepted',
    OrderStage.awaitingHandover =>
      customerDropsOff
          ? 'stage_awaiting_dropoff_at_laundry'
          : 'stage_awaiting_pickup',
    OrderStage.received => 'stage_received',
    OrderStage.inProgress => 'stage_in_progress',
    OrderStage.ready =>
      customerCollects ? 'stage_ready_for_pickup' : 'stage_ready_for_delivery',
    OrderStage.onTheWay => 'stage_driver_on_the_way',
    OrderStage.delivered => 'stage_delivered',
    OrderStage.completed => 'stage_completed',
  };

  /// النص اللي في شارة الحالة: اسم المرحلة، إلا الحالات اللي محتاجة تتقال
  /// بنفسها (تعديل مستني العميل، رفض، فشل، إلغاء)
  String get statusLabelKey => switch (status) {
    OrderStatus.adjustmentPendingApproval ||
    OrderStatus.rejected ||
    OrderStatus.pickupFailed ||
    OrderStatus.deliveryFailed ||
    OrderStatus.cancelled ||
    OrderStatus.pendingPayment => status.labelKey,
    _ => stageLabelKey(currentStage!),
  };

  /// المبلغ المستحق دلوقتي. لو السيرفر مابعتش outstandingAmount (طلب قديم)
  /// بنحسبه من الإجمالي واللي اتدفع
  num get amountDue {
    final outstanding = outstandingAmount;
    if (outstanding != null) return outstanding < 0 ? 0 : outstanding;
    if (isPaid) return 0;
    final due = grandTotal - (amountPaid ?? 0);
    return due < 0 ? 0 : due;
  }

  /// فيه مبلغ مستحق، فزرار الدفع بيظهر (ادفع الآن / ادفع الفرق).
  /// المرفوض والملغي مفيش دفع عليهم حتى لو السيرفر سايب مبلغ
  bool get needsPayment =>
      amountDue > 0 &&
      status != OrderStatus.rejected &&
      status != OrderStatus.cancelled;

  /// المستحق فرق مطابقة مش الدفع المبدئي: الطلب عدّى مرحلة الدفع الأولى
  /// واتدفع منه حاجة قبل كده (الطلبات القديمة اللي مااتدفعش منها حاجة بتبان
  /// "ادفع الآن" مش "ادفع الفرق")
  bool get isDifferenceDue =>
      needsPayment &&
      status != OrderStatus.pendingPayment &&
      (amountPaid ?? 0) > 0;

  /// مفتاح زرار الدفع حسب نوع المستحق، ولو آخر محاولة فشلت "إعادة الدفع"
  String get payActionKey {
    if (isDifferenceDue) return 'pay_difference';
    return paymentStatus == PaymentStatus.failed ? 'retry_payment' : 'pay_now';
  }

  bool get hasPaymentUrl => paymentUrl != null && paymentUrl!.isNotEmpty;

  /// رحلات الطلب اللي ليها كارت مندوب، الاستلام الأول وبعده التسليم:
  /// اللي عليها مندوب، واللي لسه مستنية مندوب والطلب شغال.
  /// المرحلة اللي العميل بيعملها بنفسه مالهاش رحلة أصلًا فمش بتظهر
  List<OrderTripModel> get driverTrips => [
    for (final trip in [pickupTrip, dropoffTrip])
      if (trip != null &&
          (trip.hasDriver ||
              (isCurrent && tripStage(trip) == DriverTripStage.awaitingDriver)))
        trip,
  ];

  /// حالة الرحلة من ناحية العميل: من حقول الرحلة الأول (اتأكدت، مستنية مين)
  /// وبعدها من حالة الطلب، لأن حالة الرحلة نفسها مش متوثقة في الـ swagger
  DriverTripStage tripStage(OrderTripModel trip) {
    final isPickup = trip.type == DeliveryTripType.pickup;
    final tripStatus = trip.status.toLowerCase();
    if (trip.isConfirmed) return DriverTripStage.completed;
    if (status ==
            (isPickup
                ? OrderStatus.pickupFailed
                : OrderStatus.deliveryFailed) ||
        tripStatus.contains('fail')) {
      return DriverTripStage.failed;
    }
    if (isTripFinished(trip)) return DriverTripStage.completed;
    if (status == OrderStatus.cancelled ||
        status == OrderStatus.rejected ||
        tripStatus.contains('cancel')) {
      return DriverTripStage.cancelled;
    }
    if (!trip.hasDriver) return DriverTripStage.awaitingDriver;

    if (isPickup) {
      // المغسلة هي اللي مستنية تدخل الكود يبقى الهدوم مع المندوب
      if (trip.awaitingConfirmationBy == TripConfirmer.laundry ||
          tripStatus.contains('collect') ||
          tripStatus.contains('transit')) {
        return DriverTripStage.toLaundry;
      }
      return trip.hasArrived
          ? DriverTripStage.arrived
          : DriverTripStage.onTheWay;
    }
    if (trip.hasArrived) return DriverTripStage.arrived;
    if (trip.isHandedOver || status == OrderStatus.outForDelivery) {
      return DriverTripStage.onTheWay;
    }
    return DriverTripStage.atLaundry;
  }

  /// الرحلة خلصت: الاستلام لما الهدوم توصل المغسلة (والطلب يعدّي مرحلة
  /// الاستلام)، والتسليم لما الطلب يتسلّم للعميل
  bool isTripFinished(OrderTripModel trip) =>
      trip.isConfirmed ||
      switch (trip.type) {
        DeliveryTripType.pickup => const {
          OrderStatus.atLaundryPendingMatch,
          OrderStatus.adjustmentPendingApproval,
          OrderStatus.inProgress,
          OrderStatus.ready,
          OrderStatus.awaitingDropoffCollection,
          OrderStatus.outForDelivery,
          OrderStatus.delivered,
          OrderStatus.deliveryFailed,
        }.contains(status),
        DeliveryTripType.dropoff => status == OrderStatus.delivered,
      };

  /// العميل يقدر يقيّم مندوب الرحلة: فيها مندوب ورقمها معروف وخلصت
  /// ولسه ماتقيّمتش (api/customer/driver-reviews بياخد رقم الرحلة)
  bool canRateDriver(OrderTripModel trip) =>
      trip.id > 0 &&
      trip.hasDriver &&
      trip.isDriverReviewed != true &&
      isTripFinished(trip);

  bool get hasLocation => isValidCoordinate(latitude, longitude);

  bool get hasLaundryLocation =>
      isValidCoordinate(laundryLatitude, laundryLongitude);

  bool get hasNotesOrImages => notes.isNotEmpty || images.isNotEmpty;

  /// مندوب التسليم عند باب العميل ومستني يسلّمه، من غير أي كود.
  /// المندوب هو اللي بيقفل الرحلة بعدها والطلب بيبقى Delivered
  bool get isDriverAtDoor =>
      status == OrderStatus.outForDelivery &&
      (dropoffTrip?.hasArrived ?? false);

  /// نسخة من الطلب بلينك دفع تاني. أحداث الـ realtime ممكن تيجي من غير
  /// لينك، فبنحتفظ باللي كان معانا بدل ما زرار الدفع يختفي
  OrderModel withPaymentUrl(String? url) => OrderModel(
    id: id,
    laundryId: laundryId,
    laundryName: laundryName,
    laundryLogo: laundryLogo,
    laundryPhone: laundryPhone,
    laundryLatitude: laundryLatitude,
    laundryLongitude: laundryLongitude,
    status: status,
    date: date,
    deliveryAddress: deliveryAddress,
    latitude: latitude,
    longitude: longitude,
    customerName: customerName,
    customerPhone: customerPhone,
    pickupContactName: pickupContactName,
    pickupContactPhone: pickupContactPhone,
    notes: notes,
    images: images,
    customerDropsOff: customerDropsOff,
    customerCollects: customerCollects,
    pickupFee: pickupFee,
    dropoffFee: dropoffFee,
    itemsTotal: itemsTotal,
    platformFee: platformFee,
    discount: discount,
    couponCode: couponCode,
    amountPaid: amountPaid,
    outstandingAmount: outstandingAmount,
    isPaid: isPaid,
    paymentMethod: paymentMethod,
    totalPrice: totalPrice,
    paymentStatus: paymentStatus,
    paymentUrl: url,
    rejectionReason: rejectionReason,
    items: items,
    pickupTrip: pickupTrip,
    dropoffTrip: dropoffTrip,
    adjustment: adjustment,
  );

  /// حقول الدفع (paymentMethod و amountPaid و outstandingAmount و isPaid)
  /// من OrderDto الرسمي. رسوم المنصة والخصم مش في الـ API لسه، فبنقرا الأسماء
  /// المتوقعة، والكوبون ممكن ييجي object جوه "coupon".
  /// ونفس الكلام للوجو المغسلة ورقمها وموقعها، وموقع العميل والملاحظات والصور
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final laundry = json.pickMap(['laundry']) ?? const <String, dynamic>{};
    final customer = json.pickMap(['customer']) ?? const <String, dynamic>{};
    final coupon = json.pickMap(['coupon']) ?? const <String, dynamic>{};
    final outstanding = json.pickNum([
      'outstandingAmount',
      'remainingAmount',
      'amountDue',
    ]);
    // isPaid من السيرفر هو الأساس، ولو مش موجود: مفيش مستحق أو الدفع نجح
    final isPaid = switch (json['isPaid']) {
      final bool paid => paid,
      _ =>
        outstanding != null
            ? outstanding <= 0
            : PaymentStatusX.fromJson(json['paymentStatus']) ==
                  PaymentStatus.successful,
    };
    var paymentStatus = PaymentStatusX.fromJson(json['paymentStatus']);
    // الدفع من المحفظة مالوش paymentStatus، فبنعرضه ناجح لو اتدفع
    if (paymentStatus == PaymentStatus.none && isPaid) {
      paymentStatus = PaymentStatus.successful;
    }

    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      laundryId: json.pickInt(['laundryId']) ?? laundry.pickInt(['id']) ?? 0,
      laundryName: _firstNotEmpty([
        json['laundryName']?.toString() ?? '',
        laundry.pickString(['name']),
      ]),
      laundryLogo: _firstNotEmpty([
        json.pickString(['laundryLogoUrl', 'laundryLogo', 'laundryImageUrl']),
        laundry.pickString(['logoUrl', 'logo', 'imageUrl']),
      ]),
      laundryPhone: _firstNotEmpty([
        json.pickString(['laundryPhoneNumber', 'laundryPhone']),
        laundry.pickString(['phoneNumber', 'phone']),
      ]),
      laundryLatitude:
          (json.pickNum(['laundryLatitude']) ?? laundry.pickNum(['latitude']))
              ?.toDouble(),
      laundryLongitude:
          (json.pickNum(['laundryLongitude']) ?? laundry.pickNum(['longitude']))
              ?.toDouble(),
      status: OrderStatusX.fromJson(json['status']),
      date:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      // نفس اللي بيتبعت مع تأكيد السلة (ConfirmOrderRequestDto)
      latitude: json.pickNum([
        'latitude',
        'deliveryLatitude',
        'lat',
      ])?.toDouble(),
      longitude: json.pickNum([
        'longitude',
        'deliveryLongitude',
        'lng',
      ])?.toDouble(),
      customerName: _firstNotEmpty([
        json.pickString(['customerName']),
        customer.pickString(['fullName', 'name']),
      ]),
      customerPhone: _firstNotEmpty([
        json.pickString(['customerPhoneNumber', 'customerPhone']),
        customer.pickString(['phoneNumber', 'phone']),
      ]),
      pickupContactName: json.pickString(['pickupContactName']),
      pickupContactPhone: json.pickString(['pickupContactPhoneNumber']),
      notes: json.pickString([
        'notes',
        'note',
        'customerNotes',
        'specialInstructions',
      ]).trim(),
      images: _readImages(json),
      // طريقة التسليم مش في الـ API لسه، فبنقرا الأسماء المتوقعة
      customerDropsOff:
          json['isSelfDropOff'] == true ||
          _isSelfHandled(json.pick(['pickupMethod', 'pickupType'])),
      customerCollects:
          json['isSelfPickup'] == true ||
          _isSelfHandled(
            json.pick(['deliveryMethod', 'dropoffMethod', 'dropoffType']),
          ),
      pickupFee: (json['pickupFee'] as num?) ?? 0,
      dropoffFee: (json['dropoffFee'] as num?) ?? 0,
      itemsTotal: (json['itemsTotal'] as num?) ?? 0,
      platformFee:
          json.pickNum(['platformFee', 'platformServiceFee', 'serviceFee']) ??
          0,
      // بالموجب دايمًا حتى لو السيرفر بعته بالسالب، عشان الطرح في الإجمالي
      discount:
          (json.pickNum(['discount', 'discountAmount', 'couponDiscount']) ??
                  coupon.pickNum(['discount', 'amount']) ??
                  0)
              .abs(),
      couponCode: _firstNotEmpty([
        json.pickString(['couponCode', 'promoCode']),
        coupon.pickString(['code']),
      ]),
      amountPaid: json.pickNum(['amountPaid', 'paidAmount']),
      outstandingAmount: outstanding,
      isPaid: isPaid,
      paymentMethod: PaymentMethodX.fromJson(json['paymentMethod']),
      totalPrice: json['totalPrice'] as num?,
      paymentStatus: paymentStatus,
      paymentUrl: json.pickString(['paymentUrl']).isEmpty
          ? null
          : json.pickString(['paymentUrl']),
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

  /// العميل هو اللي بيودّي أو بيستلم من المغسلة (SelfPickup / Customer / InStore)
  /// مش المندوب. أي قيمة تانية أو مفيش قيمة يبقى مندوب
  static bool _isSelfHandled(Object? value) {
    final text = '${value ?? ''}'.toLowerCase();
    return ['self', 'customer', 'walk', 'store', 'branch'].any(text.contains);
  }

  /// الصور ممكن تيجي لينكات على طول، أو objects فيها اللينك
  static List<String> _readImages(Map<String, dynamic> json) {
    final value = json.pick(['images', 'imageUrls', 'photos', 'attachments']);
    if (value is! List) return const [];
    return value
        .map(
          (image) => image is Map<String, dynamic>
              ? image.pickString(['url', 'imageUrl', 'path'])
              : '${image ?? ''}',
        )
        .where((url) => url.isNotEmpty)
        .toList();
  }
}

/// أول نص مش فاضي، ولو كلهم فاضيين بيرجع فاضي
String _firstNotEmpty(List<String> values) =>
    values.firstWhere((value) => value.isNotEmpty, orElse: () => '');

/// الإحداثيات موجودة ومش (0, 0) اللي السيرفر بيبعتها بدل null أحيانًا
bool isValidCoordinate(double? latitude, double? longitude) =>
    latitude != null && longitude != null && !(latitude == 0 && longitude == 0);

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
