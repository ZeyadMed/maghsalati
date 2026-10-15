import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/features/cart/data/model/cart_item_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';

/// نفس شكل منيو المغسلة بعد ما اتضاف مستوى الأنواع
final _menuJson = <String, dynamic>{
  'id': 1,
  'name': 'غسيل الملابس',
  'imageUrl': null,
  'items': [
    {
      'laundryServiceItemId': null,
      'serviceItemId': 1,
      'name': 'قميص',
      'imageUrl': null,
      'price': null,
      'subItems': [
        {
          'laundryServiceItemId': 55,
          'serviceItemId': 10102,
          'name': 'قميص كتان',
          'imageUrl': null,
          'price': 15,
          'subItems': [],
        },
        {
          'laundryServiceItemId': 56,
          'serviceItemId': 10103,
          'name': 'قميص نص كم',
          'imageUrl': null,
          'price': 10,
          'subItems': [],
        },
      ],
    },
    {
      'laundryServiceItemId': 60,
      'serviceItemId': 6,
      'name': 'حذاء رياضي',
      'imageUrl': null,
      'price': 40,
      'subItems': [],
    },
  ],
};

void main() {
  group('ServiceItemModel', () {
    final category = ServiceCategoryModel.fromJson(_menuJson);
    final shirt = category.items[0];
    final shoe = category.items[1];

    test('الـ group مالوش id ولا سعر ومش بيتضاف للسلة', () {
      expect(shirt.isGroup, isTrue);
      expect(shirt.isAddable, isFalse);
      expect(shirt.laundryServiceItemId, isNull);
      expect(shirt.price, isNull);
      expect(shirt.serviceItemId, 1);
      expect(shirt.subItems.map((e) => e.name), ['قميص كتان', 'قميص نص كم']);
    });

    test('الصنف العادي بيتضاف زي الأول', () {
      expect(shoe.isGroup, isFalse);
      expect(shoe.isAddable, isTrue);
      expect(shoe.addableItems, [shoe]);
    });

    test('كل group فرع بأنواعه، والأصناف العادية في فرع واحد في الآخر', () {
      final branches = category.branches;
      expect(branches.map((branch) => branch.name), ['قميص', null]);
      expect(branches.first.items.map((e) => e.laundryServiceItemId), [55, 56]);
      expect(branches.last.items, [shoe]);
    });

    test('ids السلة بتاعة القسم هي الأنواع والأصناف العادية بس', () {
      expect(category.laundryServiceItemIds.toList(), [55, 56, 60]);
      expect(category.itemsOf(null), [shirt, shoe]);
    });

    test('subItems null والأرقام الجاية strings مابيعملوش crash', () {
      final item = ServiceCategoryModel.fromJson({
        'id': 2,
        'items': [
          {'laundryServiceItemId': '70', 'price': '12.5', 'subItems': null},
          {'laundryServiceItemId': null, 'price': null, 'subItems': []},
        ],
        'subCategories': [
          {'id': null, 'name': null},
        ],
      });
      expect(item.id, 2);
      expect(item.items.first.laundryServiceItemId, 70);
      expect(item.items.first.price, 12.5);
      expect(item.items.first.subItems, isEmpty);
      // عنصر من غير id ومن غير أنواع مابيتعرضش ومابيتبعتش للسلة
      expect(item.items.last.isVisible, isFalse);
      expect(item.itemsOf(null), [item.items.first]);
      expect(item.laundryServiceItemIds.toList(), [70]);
      // قسم من غير groups ليه فرع واحد من غير اسم، والشاشة بتخفي الشيبس
      expect(item.branches.single.name, isNull);
      expect(item.branches.single.items, [item.items.first]);
    });
  });

  group('CartItemModel', () {
    test('بيقرا الصنف الأب للنوع', () {
      final item = CartItemModel.fromJson({
        'id': 9,
        'laundryServiceItemId': 55,
        'serviceItemName': 'قميص كتان',
        'parentItemId': 1,
        'parentItemName': 'قميص',
        'unitPrice': 15,
        'quantity': 2,
        'lineTotal': 30,
      });
      expect(item.name, 'قميص كتان');
      expect(item.parentItemId, 1);
      expect(item.parentItemName, 'قميص');
    });

    test('الصنف العادي مالوش أب', () {
      final item = CartItemModel.fromJson({
        'id': 10,
        'laundryServiceItemId': 60,
        'serviceItemName': 'حذاء رياضي',
        'parentItemId': null,
        'parentItemName': null,
      });
      expect(item.parentItemId, isNull);
      expect(item.parentItemName, isEmpty);
    });
  });
}
