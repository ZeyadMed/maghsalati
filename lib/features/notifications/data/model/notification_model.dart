/// إشعار واحد جاي من api/laundry/notifications
/// orderId و deliveryTripId بيبقوا null لو الإشعار مش مربوط بطلب أو رحلة
class NotificationModel {
  final int id;

  /// نوع الإشعار زي ما بيجي من الباك (OrderUpdated ...)، بيحدد الأيقونة
  final String type;
  final String title;
  final String body;
  final int? orderId;
  final int? deliveryTripId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.orderId,
    required this.deliveryTripId,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      orderId: orderId,
      deliveryTripId: deliveryTripId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      orderId: (json['orderId'] as num?)?.toInt(),
      deliveryTripId: (json['deliveryTripId'] as num?)?.toInt(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// صفحة من الإشعارات ومعاها بيانات الصفحات
class NotificationsPageModel {
  final int pageIndex;
  final int totalPages;
  final List<NotificationModel> notifications;

  const NotificationsPageModel({
    required this.pageIndex,
    required this.totalPages,
    required this.notifications,
  });

  /// مفيش صفحات تانية بعد دي
  bool get isLastPage => pageIndex >= totalPages;

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    return NotificationsPageModel(
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      notifications: ((json['data'] as List?) ?? [])
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
