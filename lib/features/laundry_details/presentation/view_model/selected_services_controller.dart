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
///
/// singleton في get_it عشان تاب السلة في البوتوم ناف يقرا من نفس السلة
/// اللي اتملت في شاشة تفاصيل المغسلة، فالسلة بتفضل عايشة بعد ما تخرج منها
class SelectedServicesController extends ChangeNotifier {
  final Map<int, int> _quantities = {};

  /// أسعار القطع (itemId -> السعر) عشان نحسب الإجمالي من غير ما الـ UI
  /// يلف على الأقسام كل مرة. بتتملّي من نفس الداتا الجاية من ال endpoint
  final Map<int, num> _prices = {};

  /// سعر التوصيل بينضاف على الإجمالي، وبيتحدد من بره
  num _deliveryPrice = 0;

  /// الأقسام بتاعة المغسلة اللي السلة اتملت منها، محفوظة هنا عشان تاب السلة
  /// يقدر يعرض القطع ويبني الطلب من غير ما يكون داخل من شاشة التفاصيل
  List<ServiceCategoryModel> _categories = const [];

  /// المغسلة اللي السلة تبعها، السلة كلها لمغسلة واحدة بس
  String _laundryName = '';

  Map<int, int> get quantities => Map.unmodifiable(_quantities);

  num get deliveryPrice => _deliveryPrice;

  List<ServiceCategoryModel> get categories => _categories;

  String get laundryName => _laundryName;

  /// بتتنادى مرة واحدة بعد ما الأقسام توصل عشان نعرف سعر كل قطعة
  void loadPrices(List<ServiceCategoryModel> categories) {
    _categories = categories;
    _prices.clear();
    for (final category in categories) {
      for (final ServiceItemModel item in category.items) {
        _prices[item.id] = item.price;
      }
    }
  }

  /// بيتنادى من شاشة التفاصيل أول ما تفتح عشان السلة تعرف هي لمين
  void setLaundryName(String name) {
    if (_laundryName == name) return;
    _laundryName = name;
  }

  /// السلة لمغسلة واحدة بس، فلو فيها حاجة من مغسلة تانية بترجع true
  /// والشاشة بتسأل المستخدم يمسح القديم الأول
  bool belongsToOtherLaundry(String name) =>
      _quantities.isNotEmpty && _laundryName.isNotEmpty && _laundryName != name;

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

  /// القطع المختارة من الأقسام المحفوظة، تاب السلة بيستخدمها عشان
  /// مامعهوش الأقسام في إيده زي شاشة التفاصيل
  List<SelectedService> get currentSelection => selectedServices(_categories);

  void clear() {
    if (_quantities.isEmpty) return;
    _quantities.clear();
    notifyListeners();
  }
}
