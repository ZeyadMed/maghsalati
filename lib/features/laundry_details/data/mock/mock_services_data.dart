import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';

/// داتا تجريبية للعرض بس لحد ما ال endpoint يجهز
/// مكتوبة بنفس شكل الـ json اللي هييجي من السيرفر وبتتحول بـ fromJson
/// فلما الـ API يتوصل بنمسح الملف ده وخلاص من غير ما يتغير أي widget
abstract final class MockServicesData {
  static const List<Map<String, dynamic>> _json = [
    {
      'id': 1,
      'name': 'ملابس',
      'image': '👕',
      'items': [
        {'id': 101, 'name': 'قميص', 'price': 3, 'unit': 'قطعة'},
        {'id': 102, 'name': 'تيشيرت', 'price': 2, 'unit': 'قطعة'},
        {'id': 103, 'name': 'بنطلون', 'price': 3.5, 'unit': 'قطعة'},
        {'id': 104, 'name': 'جينز', 'price': 4, 'unit': 'قطعة'},
        {'id': 105, 'name': 'جاكيت', 'price': 5, 'unit': 'قطعة'},
        {'id': 106, 'name': 'شورت', 'price': 2, 'unit': 'قطعة'},
      ],
    },
    {
      'id': 2,
      'name': 'بدل',
      'image': '🤵',
      'items': [
        {'id': 201, 'name': 'بدلة كاملة', 'price': 12, 'unit': 'قطعة'},
        {'id': 202, 'name': 'جاكيت بدلة', 'price': 7, 'unit': 'قطعة'},
        {'id': 203, 'name': 'بنطلون بدلة', 'price': 5, 'unit': 'قطعة'},
      ],
    },
    {
      'id': 3,
      'name': 'فساتين',
      'image': '👗',
      'items': [
        {'id': 301, 'name': 'فستان سهرة', 'price': 15, 'unit': 'قطعة'},
        {'id': 302, 'name': 'فستان عادي', 'price': 8, 'unit': 'قطعة'},
        {'id': 303, 'name': 'عباية', 'price': 6, 'unit': 'قطعة'},
        {'id': 304, 'name': 'تنورة', 'price': 4, 'unit': 'قطعة'},
      ],
    },
    {
      'id': 4,
      'name': 'مفروشات',
      'image': '🛏️',
      'items': [
        {'id': 401, 'name': 'ملاية سرير', 'price': 6, 'unit': 'قطعة'},
        {'id': 402, 'name': 'لحاف', 'price': 10, 'unit': 'قطعة'},
        {'id': 403, 'name': 'مخدة', 'price': 2.5, 'unit': 'قطعة'},
        {'id': 404, 'name': 'بطانية', 'price': 9, 'unit': 'قطعة'},
      ],
    },
    {
      'id': 5,
      'name': 'سجاد',
      'image': '🧶',
      'items': [
        {'id': 501, 'name': 'سجادة صغيرة', 'price': 10, 'unit': 'متر'},
        {'id': 502, 'name': 'سجادة كبيرة', 'price': 20, 'unit': 'متر'},
        {'id': 503, 'name': 'موكيت', 'price': 15, 'unit': 'متر'},
      ],
    },
  ];

  static List<ServiceCategoryModel> get categories =>
      _json.map(ServiceCategoryModel.fromJson).toList();
}
