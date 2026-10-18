import 'package:easy_localization/easy_localization.dart';

/// الراجع من api/customer/laundries/{laundryId}/working-hours
class WorkingHoursModel {
  final bool isAvailableNow;
  final List<WorkingDayModel> days;

  const WorkingHoursModel({required this.isAvailableNow, required this.days});

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      isAvailableNow: json['isAvailableNow'] == true,
      days:
          (json['workingHours'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(WorkingDayModel.fromJson)
              .toList()
            // بنرتب الأيام من السبت للجمعة مهما كان الترتيب الراجع من الباك
            ..sort((a, b) => a.weekIndex.compareTo(b.weekIndex)),
    );
  }
}

/// يوم واحد من مواعيد العمل، ولو [isClosed] يبقى اليوم ده أجازة
class WorkingDayModel {
  final int id;

  /// اسم اليوم بالإنجليزي زي ما راجع من الباك 'Sunday'
  final String dayOfWeek;

  /// بالشكل 'HH:mm:ss' وبترجع null في أيام الأجازة
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  const WorkingDayModel({
    required this.id,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory WorkingDayModel.fromJson(Map<String, dynamic> json) {
    return WorkingDayModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dayOfWeek: json['dayOfWeek']?.toString() ?? '',
      openTime: json['openTime']?.toString(),
      closeTime: json['closeTime']?.toString(),
      isClosed: json['isClosed'] == true,
    );
  }

  /// الأسبوع بيبدأ من السبت
  static const _weekOrder = [
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  /// مفتاح الترجمة لاسم اليوم زي 'sunday'
  String get dayKey => dayOfWeek.toLowerCase();

  /// ترتيب اليوم في الأسبوع، واليوم اللي مش معروف بيروح في الآخر
  int get weekIndex {
    final index = _weekOrder.indexOf(dayKey);
    return index == -1 ? _weekOrder.length : index;
  }

  /// لو الباك قال مفتوح بس نسي يبعت المواعيد بنعتبره مقفول بدل ما نعرض null
  bool get isOff => isClosed || openTime == null || closeTime == null;

  /// الميعاد دايماً بالإنجليزي وبصيغة 12 ساعة زي '9:00 AM to 10:00 PM'
  /// حتى لو التطبيق عربي
  String get formattedRange =>
      '${_formatTime(openTime!)} to ${_formatTime(closeTime!)}';

  static String _formatTime(String time) {
    try {
      // en_US مدمجة في intl فمش محتاجة initializeDateFormatting
      return DateFormat(
        'h:mm a',
        'en_US',
      ).format(DateFormat('HH:mm:ss', 'en_US').parse(time));
    } catch (_) {
      // لو الشكل جه مختلف نعرضه زي ما هو أحسن ما الديالوج يقع
      return time;
    }
  }
}
