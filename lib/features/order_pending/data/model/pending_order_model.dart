/// سطر واحد في تفاصيل الطلب (اسم القطعة + الكمية + سعر القطعة)
/// الشاشة بتحسب الإجمالي من السطور دي فمفيش رقم ثابت متكتوب
class PendingOrderLine {
  final int itemId;
  final String name;
  final int quantity;
  final num price;

  const PendingOrderLine({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  num get total => price * quantity;
}

/// الطلب اللي اتبعت للمغسلة وبيستنى موافقتها
/// بيتبني في شاشة تفاصيل المغسلة من الكميات المختارة وبيتبعت هنا
class PendingOrderModel {
  final String laundryName;
  final List<PendingOrderLine> lines;

  /// سعر التوصيل بينضاف على الإجمالي زي ما في البار تحت
  final num deliveryPrice;

  const PendingOrderModel({
    required this.laundryName,
    required this.lines,
    this.deliveryPrice = 0,
  });

  num get servicesTotal =>
      lines.fold<num>(0, (sum, line) => sum + line.total);

  num get grandTotal => lines.isEmpty ? 0 : servicesTotal + deliveryPrice;

  int get totalPieces => lines.fold(0, (sum, line) => sum + line.quantity);
}
