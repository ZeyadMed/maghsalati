import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';

/// داتا تجريبية للعرض بس لحد ما ال endpoint يجهز
/// مكتوبة بنفس شكل الـ json اللي هييجي من السيرفر وبتتحول بـ fromJson
/// فلما الـ API يتوصل بنمسح الملف ده وخلاص من غير ما يتغير أي widget
abstract final class MockServicesData {
  static const List<Map<String, dynamic>> _json = [
    {
      'id': 1,
      'name': 'ملابس',
      'image':
          'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=400',
      'sub_categories': [
        {'id': 11, 'name': 'قمصان'},
        {'id': 12, 'name': 'بناطيل'},
        {'id': 13, 'name': 'فساتين'},
        {'id': 14, 'name': 'جواكت'},
      ],
      'items': [
        {
          'id': 101,
          'name': 'قميص رجالي',
          'price': 15,
          'unit': 'قطعة',
          'sub_category_id': 11,
          'image': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400',
        },
        {
          'id': 102,
          'name': 'تيشيرت',
          'price': 12,
          'unit': 'قطعة',
          'sub_category_id': 11,
          'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
        },
        {
          'id': 103,
          'name': 'بنطال قماش',
          'price': 18,
          'unit': 'قطعة',
          'sub_category_id': 12,
          'image': 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400',
        },
        {
          'id': 104,
          'name': 'بنطال جينز',
          'price': 20,
          'unit': 'قطعة',
          'sub_category_id': 12,
          'image':
              'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
        },
        {
          'id': 105,
          'name': 'فستان',
          'price': 35,
          'unit': 'قطعة',
          'sub_category_id': 13,
          'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
        },
        {
          'id': 106,
          'name': 'جاكيت',
          'price': 25,
          'unit': 'قطعة',
          'sub_category_id': 14,
          'image':
              'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        },
        {
          'id': 107,
          'name': 'معطف شتوي',
          'price': 40,
          'unit': 'قطعة',
          'sub_category_id': 14,
          'image':
              'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=400',
        },
      ],
    },
    {
      'id': 2,
      'name': 'بدل',
      'image':
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400',
      'sub_categories': [
        {'id': 21, 'name': 'بدل كاملة'},
        {'id': 22, 'name': 'قطع منفصلة'},
      ],
      'items': [
        {
          'id': 201,
          'name': 'بدلة رسمية',
          'price': 50,
          'unit': 'قطعة',
          'sub_category_id': 21,
          'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        },
        {
          'id': 202,
          'name': 'بدلة كاملة',
          'price': 55,
          'unit': 'قطعة',
          'sub_category_id': 21,
          'image':
              'https://images.unsplash.com/photo-1553240799-36bbf332a5c3?w=400',
        },
        {
          'id': 203,
          'name': 'جاكيت بدلة',
          'price': 30,
          'unit': 'قطعة',
          'sub_category_id': 22,
          'image': 'https://images.unsplash.com/photo-1592878940526-0214b0f374f6?w=400',
        },
        {
          'id': 204,
          'name': 'بنطلون بدلة',
          'price': 22,
          'unit': 'قطعة',
          'sub_category_id': 22,
          'image': 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400',
        },
      ],
    },
    {
      'id': 3,
      'name': 'فساتين',
      'image':
          'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=400',
      'sub_categories': [
        {'id': 31, 'name': 'سهرة'},
        {'id': 32, 'name': 'يومي'},
      ],
      'items': [
        {
          'id': 301,
          'name': 'فستان سهرة',
          'price': 60,
          'unit': 'قطعة',
          'sub_category_id': 31,
          'image': 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=400',
        },
        {
          'id': 302,
          'name': 'فستان زفاف',
          'price': 120,
          'unit': 'قطعة',
          'sub_category_id': 31,
          'image': 'https://images.unsplash.com/photo-1594552072238-b8a33785b261?w=400',
        },
        {
          'id': 303,
          'name': 'فستان عادي',
          'price': 30,
          'unit': 'قطعة',
          'sub_category_id': 32,
          'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
        },
        {
          'id': 304,
          'name': 'عباية',
          'price': 25,
          'unit': 'قطعة',
          'sub_category_id': 32,
          'image': 'https://images.unsplash.com/photo-1583391733956-6c78276477e2?w=400',
        },
      ],
    },
    {
      'id': 4,
      'name': 'أحذية',
      'image':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      'sub_categories': [
        {'id': 41, 'name': 'رياضي'},
        {'id': 42, 'name': 'كلاسيك'},
      ],
      'items': [
        {
          'id': 401,
          'name': 'حذاء رياضي',
          'price': 22,
          'unit': 'زوج',
          'sub_category_id': 41,
          'image':
              'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        },
        {
          'id': 402,
          'name': 'حذاء كلاسيك',
          'price': 28,
          'unit': 'زوج',
          'sub_category_id': 42,
          'image': 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=400',
        },
        {
          'id': 403,
          'name': 'بوت جلد',
          'price': 35,
          'unit': 'زوج',
          'sub_category_id': 42,
          'image': 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=400',
        },
      ],
    },
    {
      'id': 5,
      'name': 'مفروشات',
      'image':
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400',
      'sub_categories': [
        {'id': 51, 'name': 'مفارش'},
        {'id': 52, 'name': 'بطاطين'},
      ],
      'items': [
        {
          'id': 501,
          'name': 'ملاية سرير',
          'price': 20,
          'unit': 'قطعة',
          'sub_category_id': 51,
          'image': 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400',
        },
        {
          'id': 502,
          'name': 'مخدة',
          'price': 10,
          'unit': 'قطعة',
          'sub_category_id': 51,
          'image': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400',
        },
        {
          'id': 503,
          'name': 'بطانية',
          'price': 30,
          'unit': 'قطعة',
          'sub_category_id': 52,
          'image': 'https://images.unsplash.com/photo-1616627561950-9f746e330187?w=400',
        },
        {
          'id': 504,
          'name': 'لحاف',
          'price': 35,
          'unit': 'قطعة',
          'sub_category_id': 52,
          'image': 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        },
      ],
    },
    {
      'id': 6,
      'name': 'حقائب',
      'image':
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400',
      'sub_categories': [
        {'id': 61, 'name': 'يد'},
        {'id': 62, 'name': 'سفر'},
      ],
      'items': [
        {
          'id': 601,
          'name': 'حقيبة يد',
          'price': 30,
          'unit': 'قطعة',
          'sub_category_id': 61,
          'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400',
        },
        {
          'id': 602,
          'name': 'حقيبة ظهر',
          'price': 25,
          'unit': 'قطعة',
          'sub_category_id': 61,
          'image':
              'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        },
        {
          'id': 603,
          'name': 'شنطة سفر',
          'price': 45,
          'unit': 'قطعة',
          'sub_category_id': 62,
          'image': 'https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?w=400',
        },
      ],
    },
    {
      'id': 7,
      'name': 'ستائر',
      'image':
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400',
      'sub_categories': [],
      'items': [
        {
          'id': 701,
          'name': 'ستارة قماش',
          'price': 40,
          'unit': 'متر',
          'image': 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400',
        },
        {
          'id': 702,
          'name': 'ستارة بلاك اوت',
          'price': 55,
          'unit': 'متر',
          'image': 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=400',
        },
      ],
    },
    {
      'id': 8,
      'name': 'ملابس أطفال',
      'image':
          'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=400',
      'sub_categories': [],
      'items': [
        {
          'id': 801,
          'name': 'تيشيرت أطفال',
          'price': 8,
          'unit': 'قطعة',
          'image': 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=400',
        },
        {
          'id': 802,
          'name': 'بنطلون أطفال',
          'price': 10,
          'unit': 'قطعة',
          'image':
              'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=400',
        },
      ],
    },
    {
      'id': 9,
      'name': 'تنظيف جاف',
      'image':
          'https://images.unsplash.com/photo-1545173168-9f1947eebb7f?w=400',
      'sub_categories': [],
      'items': [
        {
          'id': 901,
          'name': 'تنظيف جاف - قطعة',
          'price': 25,
          'unit': 'قطعة',
          'image':
              'https://images.unsplash.com/photo-1545173168-9f1947eebb7f?w=400',
        },
      ],
    },
    {
      'id': 10,
      'name': 'خدمات خاصة',
      'image':
          'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=400',
      'sub_categories': [],
      'items': [
        {
          'id': 1001,
          'name': 'كي فقط',
          'price': 5,
          'unit': 'قطعة',
          'image': 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=400',
        },
        {
          'id': 1002,
          'name': 'إزالة بقع',
          'price': 15,
          'unit': 'قطعة',
          'image': 'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=400',
        },
      ],
    },
  ];

  static List<ServiceCategoryModel> get categories =>
      _json.map(ServiceCategoryModel.fromJson).toList();
}
