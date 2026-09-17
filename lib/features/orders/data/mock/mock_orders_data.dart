import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// داتا تجريبية للعرض بس لحد ما ال endpoint يجهز
/// مكتوبة بنفس شكل الـ json اللي هييجي من السيرفر وبتتحول بـ fromJson
/// فلما الـ API يتوصل بنمسح الملف ده وخلاص من غير ما يتغير أي widget
abstract final class MockOrdersData {
  static const List<Map<String, dynamic>> _json = [
    {
      'id': 1,
      'reference': 'ORD-2045',
      'laundry_name': 'مغسلة النخبة',
      'status': 'washing',
      'date': '2026-09-13',
      'delivery_eta': 'tomorrow',
      'delivery_price': 8,
      'items': [
        {
          'id': 101,
          'name': 'قميص رجالي',
          'quantity': 3,
          'price': 15,
          'image':
              'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400',
        },
        {
          'id': 103,
          'name': 'بنطلون',
          'quantity': 2,
          'price': 18,
          'image':
              'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400',
        },
        {
          'id': 106,
          'name': 'جاكيت',
          'quantity': 1,
          'price': 25,
          'image':
              'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        },
      ],
    },
    {
      'id': 2,
      'reference': 'ORD-2041',
      'laundry_name': 'مغسلة النخبة',
      'status': 'completed',
      'date': '2026-09-10',
      'delivery_price': 8,
      'items': [
        {
          'id': 101,
          'name': 'قميص رجالي',
          'quantity': 3,
          'price': 15,
          'image':
              'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400',
        },
        {
          'id': 103,
          'name': 'بنطلون',
          'quantity': 2,
          'price': 18,
          'image':
              'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400',
        },
        {
          'id': 102,
          'name': 'بدلة',
          'quantity': 1,
          'price': 45,
          'image':
              'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400',
        },
        {
          'id': 105,
          'name': 'تيشيرت',
          'quantity': 2,
          'price': 12,
          'image':
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
        },
      ],
    },
    {
      'id': 3,
      'reference': 'ORD-2038',
      'laundry_name': 'مغسلة الفاخرة',
      'status': 'completed',
      'date': '2026-09-03',
      'delivery_price': 10,
      'items': [
        {
          'id': 107,
          'name': 'فستان سهرة',
          'quantity': 1,
          'price': 35,
          'image':
              'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
        },
        {
          'id': 108,
          'name': 'معطف Dry Clean',
          'quantity': 2,
          'price': 40,
          'image':
              'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=400',
        },
        {
          'id': 109,
          'name': 'بدلة كاملة',
          'quantity': 2,
          'price': 45,
          'image':
              'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400',
        },
      ],
    },
    {
      'id': 4,
      'reference': 'ORD-2029',
      'laundry_name': 'مغسلة الأمانة',
      'status': 'cancelled',
      'date': '2026-08-25',
      'delivery_price': 6,
      'items': [
        {
          'id': 101,
          'name': 'قميص رجالي',
          'quantity': 4,
          'price': 15,
          'image':
              'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400',
        },
      ],
    },
  ];

  /// الطلبات كلها، والشاشة هي اللي بتفلترها لحالية وسابقة
  static List<OrderModel> get orders =>
      _json.map(OrderModel.fromJson).toList();
}
