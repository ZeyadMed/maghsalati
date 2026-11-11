import 'dart:math' as math;

import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// نوع سطر الحساب في الفاتورة، والشاشة والـ PDF بيلونوه على حسبه
enum InvoiceLineKind {
  /// مبلغ على العميل (الخدمات والرسوم)
  charge,

  /// خصم أو كوبون، بيتعرض بالسالب
  discount,

  /// اللي اتدفع
  paid,

  /// الباقي على العميل
  remaining,

  /// الإجمالي النهائي، آخر سطر ومميز
  total,
}

/// سطر في حساب الفاتورة: مفتاح الترجمة والمبلغ ونوعه
class InvoiceLine {
  final String labelKey;
  final num amount;
  final InvoiceLineKind kind;

  /// تفصيلة بتتكتب جنب الاسم زي كود الكوبون، فاضية لو مفيش
  final String note;

  const InvoiceLine(this.labelKey, this.amount, this.kind, {this.note = ''});
}

/// فاتورة الطلب المكتمل، بتتحسب من [OrderModel] مرة واحدة والشاشة والـ PDF
/// بياخدوا منها نفس الأسطر بنفس الترتيب
class OrderInvoice {
  final int orderId;
  final String reference;
  final String laundryName;
  final DateTime date;

  /// مفتاح ترجمة طريقة الدفع
  final String paymentMethodKey;

  /// القطع اللي اتحاسب عليها بس، المرتجعة من غير غسيل مش منها
  final List<OrderItemModel> items;

  final num servicesTotal;
  final num pickupFee;
  final num dropoffFee;
  final num platformFee;
  final num discount;
  final String couponCode;
  final num paidAmount;
  final num remainingAmount;
  final num total;

  const OrderInvoice({
    required this.orderId,
    required this.reference,
    required this.laundryName,
    required this.date,
    required this.paymentMethodKey,
    required this.items,
    required this.servicesTotal,
    required this.pickupFee,
    required this.dropoffFee,
    required this.platformFee,
    required this.discount,
    required this.couponCode,
    required this.paidAmount,
    required this.remainingAmount,
    required this.total,
  });

  /// المدفوع (amountPaid) والباقي (outstandingAmount) من السيرفر، ولو طلب
  /// قديم مابعتهمش: مدفوع يبقى الإجمالي كله اتدفع، وإلا الإجمالي كله باقي
  factory OrderInvoice.fromOrder(OrderModel order) {
    final items = order.items.where((item) => !item.isReturned).toList();
    final total = order.grandTotal;
    final paid = order.amountPaid ?? (order.isPaid ? total : 0);

    return OrderInvoice(
      orderId: order.id,
      reference: order.reference,
      laundryName: order.laundryName,
      date: order.date,
      paymentMethodKey: paymentMethodKeyOf(order.paymentMethod),
      items: items,
      // لو السيرفر مابعتش مجموع القطع بنجمعه من القطع نفسها
      servicesTotal: order.itemsTotal > 0
          ? order.itemsTotal
          : items.fold<num>(0, (sum, item) => sum + item.total),
      pickupFee: order.pickupFee,
      dropoffFee: order.dropoffFee,
      platformFee: order.platformFee,
      discount: order.discount,
      couponCode: order.couponCode,
      paidAmount: paid,
      remainingAmount: order.outstandingAmount ?? math.max(total - paid, 0),
      total: total,
    );
  }

  /// الطلب ماعليهوش أي مبلغ باقي
  bool get isFullyPaid => remainingAmount <= 0;

  /// اسم ملف الـ PDF
  String get fileName => 'invoice-$orderId.pdf';

  /// أسطر الحساب بالترتيب المطلوب. رسوم المنصة والباقي بيظهروا بس لو موجودين
  List<InvoiceLine> get lines => [
    InvoiceLine(
      'invoice_services_value',
      servicesTotal,
      InvoiceLineKind.charge,
    ),
    InvoiceLine('invoice_pickup_fee', pickupFee, InvoiceLineKind.charge),
    InvoiceLine('invoice_dropoff_fee', dropoffFee, InvoiceLineKind.charge),
    if (platformFee > 0)
      InvoiceLine('invoice_platform_fee', platformFee, InvoiceLineKind.charge),
    InvoiceLine(
      'invoice_discount',
      discount,
      InvoiceLineKind.discount,
      note: couponCode,
    ),
    InvoiceLine('invoice_paid_amount', paidAmount, InvoiceLineKind.paid),
    if (remainingAmount > 0)
      InvoiceLine(
        'invoice_remaining_amount',
        remainingAmount,
        InvoiceLineKind.remaining,
      ),
    InvoiceLine('invoice_final_total', total, InvoiceLineKind.total),
  ];

  /// المحفظة أو البوابة، ولو السيرفر مابعتش الطريقة (طلب قديم) بنعرضها إلكتروني
  static String paymentMethodKeyOf(PaymentMethod? method) =>
      (method ?? PaymentMethod.gateway).labelKey;
}
