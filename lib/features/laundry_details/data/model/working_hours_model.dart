import 'package:easy_localization/easy_localization.dart';

/// الراجع من api/customer/laundries/{laundryId}/working-hours
class WorkingHoursModel {
  final bool isAvailableNow;
  final List<WorkingDayModel> days;

  const WorkingHoursModel({required this.isAvailableNow, required this.days});

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      isAvailableNow: json['isAvailableNow'] == true,
      days: (json['workingHours'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(WorkingDayModel.fromJson)
          .toList(),
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

  /// مفتاح الترجمة لاسم اليوم زي 'sunday'
  String get dayKey => dayOfWeek.toLowerCase();

  /// لو الباك قال مفتوح بس نسي يبعت المواعيد بنعتبره مقفول بدل ما نعرض null
  bool get isOff => isClosed || openTime == null || closeTime == null;

  /// الميعاد بصيغة 12 ساعة حسب لغة التطبيق زي '12:00 م - 11:00 م'
  String formattedRange(String locale) =>
      '${_formatTime(openTime!, locale)} - ${_formatTime(closeTime!, locale)}';

  static String _formatTime(String time, String locale) {
    try {
      return DateFormat(
        'h:mm a',
        locale,
      ).format(DateFormat('HH:mm:ss').parse(time));
    } catch (_) {
      // لو الشكل جه مختلف نعرضه زي ما هو أحسن ما الديالوج يقع
      return time;
    }
  }
}
