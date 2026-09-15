import 'package:flutter/foundation.dart';

import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_item_model.dart';

/// قطعة مختارة ومعاها كميتها، بترجع من الكنترولر وقت تأكيد الطلب
class SelectedService {
  final ServiceItemModel item;
  final int quantity;

  const SelectedService({required this.item, required this.quantity});
}

/// بيمسك الكميات المختارة لكل قطعة (itemId -> الكمية)
/// مفصول عن الـ UI عشان لما الداتا تيجي من ال endpoint مايتأثرش حاجة،
/// وكمان عشان الشاشة تقدر تقرا الطلب كله وتبعته بعدين
class SelectedServicesController extends ChangeNotifier {
  final Map<int, int> _quantities = {};

  /// أسعار القطع (itemId -> السعر) عشان نحسب الإجمالي من غير ما الـ UI
  /// يلف على الأقسام كل مرة. بتتملّي من نفس الداتا الجاية من ال endpoint
  final Map<int, num> _prices = {};

  /// سعر التوصيل بينضاف على الإجمالي، وبيتحدد من بره
  num _deliveryPrice = 0;

  Map<int, int> get quantities => Map.unmodifiable(_quantities);

  num get deliveryPrice => _deliveryPrice;

  /// بتتنادى مرة واحدة بعد ما الأقسام توصل عشان نعرف سعر كل قطعة
  void loadPrices(List<ServiceCategoryModel> categories) {
    _prices.clear();
    for (final category in categories) {
      for (final ServiceItemModel item in category.items) {
        _prices[item.id] = item.price;
      }
    }
  }

  void setDeliveryPrice(num price) {
    if (_deliveryPrice == price) return;
    _deliveryPrice = price;
    notifyListeners();
  }

  /// إجمالي سعر القطع المختارة من غير التوصيل
  num get servicesTotal => _quantities.entries.fold<num>(
    0,
    (sum, entry) => sum + (_prices[entry.key] ?? 0) * entry.value,
  );

  /// الإجمالي اللي بيظهر في البار تحت = القطع + التوصيل
  /// ولو مفيش حاجة مختارة بيرجع صفر عشان مانحسبش توصيل على طلب فاضي
  num get grandTotal =>
      _quantities.isEmpty ? 0 : servicesTotal + _deliveryPrice;

  bool get hasSelection => _quantities.isNotEmpty;

  /// الكمية المختارة لقطعة معينة، صفر يعني مش مختارة
  int quantityOf(int itemId) => _quantities[itemId] ?? 0;

  bool isSelected(int itemId) => quantityOf(itemId) > 0;

  /// إجمالي عدد القطع في قسم معين (مش عدد الخدمات)
  int totalPiecesOf(Iterable<int> itemIds) =>
      itemIds.fold(0, (sum, id) => sum + quantityOf(id));

  /// إجمالي عدد القطع في الطلب كله
  int get totalPieces => _quantities.values.fold(0, (sum, q) => sum + q);

  /// أول مرة تدوس على + بتتحول القطعة لمختارة بكمية 1
  void select(int itemId) {
    if (isSelected(itemId)) return;
    _quantities[itemId] = 1;
    notifyListeners();
  }

  void increment(int itemId) {
    _quantities[itemId] = quantityOf(itemId) + 1;
    notifyListeners();
  }

  /// لما الكمية توصل لصفر القطعة بتترفع من الاختيار وترجع تاني علامة +
  void decrement(int itemId) {
    final next = quantityOf(itemId) - 1;
    if (next <= 0) {
      _quantities.remove(itemId);
    } else {
      _quantities[itemId] = next;
    }
    notifyListeners();
  }

  /// بيرجع القطع المختارة بس (بالكمية بتاعتها) بترتيب الأقسام
  /// الشاشة بتاخدها وتحولها لطلب، فالكنترولر مايعرفش حاجة عن شاشة التأكيد
  /// وبتلف على الأقسام مرة واحدة وقت التأكيد بس، مش في كل build
  List<SelectedService> selectedServices(
    List<ServiceCategoryModel> categories,
  ) {
    final selected = <SelectedService>[];
    for (final category in categories) {
      for (final ServiceItemModel item in category.items) {
        final quantity = quantityOf(item.id);
        if (quantity <= 0) continue;
        selected.add(SelectedService(item: item, quantity: quantity));
      }
    }
    return selected;
  }

  void clear() {
    if (_quantities.isEmpty) return;
    _quantities.clear();
    notifyListeners();
  }
}
