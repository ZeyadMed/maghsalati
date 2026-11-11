import 'dart:convert';
import 'dart:io';
import 'dart:ui';

// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter_test/flutter_test.dart';
// في التطبيق flutter_localizations بتحمّل بيانات التواريخ العربي، وهنا لازم نحملها
// ignore: depend_on_referenced_packages
import 'package:intl/date_symbol_data_local.dart';
import 'package:maghsalati/features/orders/data/model/order_invoice.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/order_invoice_pdf.dart';

OrderModel _order({
  OrderStatus status = OrderStatus.delivered,
  PaymentStatus paymentStatus = PaymentStatus.successful,
  num itemsTotal = 100,
  num platformFee = 0,
  num discount = 0,
  String couponCode = '',
  num? paidAmount,
  num? remainingAmount,
  num? totalPrice,
  PaymentMethod? paymentMethod,
  List<OrderItemModel> items = const [],
}) {
  return OrderModel(
    id: 42,
    laundryName: 'مغسلة النور',
    status: status,
    date: DateTime(2026, 10, 19, 14, 30),
    deliveryAddress: '',
    pickupFee: 10,
    dropoffFee: 15,
    itemsTotal: itemsTotal,
    items: items,
    platformFee: platformFee,
    discount: discount,
    couponCode: couponCode,
    amountPaid: paidAmount,
    outstandingAmount: remainingAmount,
    // زي fromJson: من غير isPaid من السيرفر، الدفع الناجح يعني مدفوع
    isPaid: paymentStatus == PaymentStatus.successful,
    paymentMethod: paymentMethod,
    totalPrice: totalPrice,
    paymentStatus: paymentStatus,
  );
}

List<String> _labels(OrderInvoice invoice) =>
    invoice.lines.map((line) => line.labelKey).toList();

void main() {
  group('OrderInvoice', () {
    test('الأسطر بالترتيب المطلوب لما كل حاجة موجودة', () {
      final invoice = OrderInvoice.fromOrder(
        _order(
          platformFee: 5,
          discount: 20,
          couponCode: 'SAVE20',
          paidAmount: 60,
          paymentStatus: PaymentStatus.pending,
        ),
      );

      expect(_labels(invoice), [
        'invoice_services_value',
        'invoice_pickup_fee',
        'invoice_dropoff_fee',
        'invoice_platform_fee',
        'invoice_discount',
        'invoice_paid_amount',
        'invoice_remaining_amount',
        'invoice_final_total',
      ]);
      // 100 + 10 + 15 + 5 - 20
      expect(invoice.total, 110);
      expect(invoice.remainingAmount, 50);
      expect(invoice.lines[4].note, 'SAVE20');
      expect(invoice.isFullyPaid, isFalse);
    });

    test('رسوم المنصة والباقي مابيظهروش لو صفر، والخصم بيفضل ظاهر', () {
      final invoice = OrderInvoice.fromOrder(_order());

      expect(_labels(invoice), [
        'invoice_services_value',
        'invoice_pickup_fee',
        'invoice_dropoff_fee',
        'invoice_discount',
        'invoice_paid_amount',
        'invoice_final_total',
      ]);
      expect(invoice.lines[3].amount, 0);
    });

    test('من غير مبالغ من السيرفر: المدفوع والباقي من حالة الدفع', () {
      final paid = OrderInvoice.fromOrder(_order());
      expect(paid.paidAmount, 125);
      expect(paid.remainingAmount, 0);
      expect(paid.isFullyPaid, isTrue);

      final unpaid = OrderInvoice.fromOrder(
        _order(paymentStatus: PaymentStatus.failed),
      );
      expect(unpaid.paidAmount, 0);
      expect(unpaid.remainingAmount, 125);
    });

    test('الإجمالي والباقي من السيرفر ليهم الأولوية على الحساب', () {
      final invoice = OrderInvoice.fromOrder(
        _order(totalPrice: 130, paidAmount: 100, remainingAmount: 30),
      );

      expect(invoice.total, 130);
      expect(invoice.paidAmount, 100);
      expect(invoice.remainingAmount, 30);
    });

    test(
      'القطع المرتجعة مش في الفاتورة، والمجموع منها لو السيرفر مابعتهوش',
      () {
        final invoice = OrderInvoice.fromOrder(
          _order(
            itemsTotal: 0,
            items: const [
              OrderItemModel(
                id: 1,
                name: 'قميص',
                quantity: 2,
                price: 5,
                total: 10,
              ),
              OrderItemModel(
                id: 2,
                name: 'بنطلون',
                quantity: 1,
                price: 8,
                total: 8,
                isReturned: true,
              ),
            ],
          ),
        );

        expect(invoice.items.map((item) => item.name), ['قميص']);
        expect(invoice.servicesTotal, 10);
      },
    );

    test(
      'طريقة الدفع: المحفظة أو البوابة، والطلب القديم من غير طريقة إلكتروني',
      () {
        expect(
          OrderInvoice.paymentMethodKeyOf(PaymentMethod.wallet),
          'payment_method_wallet',
        );
        expect(
          OrderInvoice.paymentMethodKeyOf(PaymentMethod.gateway),
          'payment_method_online',
        );
        expect(OrderInvoice.paymentMethodKeyOf(null), 'payment_method_online');
      },
    );
  });

  group('OrderModel', () {
    test('الفاتورة للطلبات المكتملة بس', () {
      for (final status in OrderStatus.values) {
        expect(
          _order(status: status).hasInvoice,
          status == OrderStatus.delivered,
          reason: status.name,
        );
      }
    });

    test('حقول الفاتورة بتتقري من الـ JSON، والخصم بالموجب دايمًا', () {
      final order = OrderModel.fromJson({
        'id': 7,
        'status': 'Delivered',
        'itemsTotal': 50,
        'pickupFee': 5,
        'dropoffFee': 5,
        'platformFee': 2,
        'coupon': {'code': 'WELCOME', 'discount': -10},
        'amountPaid': 52,
        'paymentMethod': 'Wallet',
      });

      expect(order.platformFee, 2);
      expect(order.discount, 10);
      expect(order.couponCode, 'WELCOME');
      expect(order.amountPaid, 52);
      expect(order.outstandingAmount, isNull);
      expect(order.paymentMethod, PaymentMethod.wallet);
      expect(order.grandTotal, 52);
    });
  });

  group('OrderModel payment', () {
    test('طلب بوابة لسه مادفعش: PendingPayment ومعاه لينك ومستحق كله', () {
      final order = OrderModel.fromJson({
        'id': 9,
        'status': 'PendingPayment',
        'totalPrice': 80,
        'paymentMethod': 'Gateway',
        'amountPaid': 0,
        'outstandingAmount': 80,
        'paymentUrl': 'https://pay.example/abc',
        'paymentStatus': 'Pending',
        'isPaid': false,
      });

      expect(order.status, OrderStatus.pendingPayment);
      expect(order.isCurrent, isTrue);
      expect(order.paymentMethod, PaymentMethod.gateway);
      expect(order.hasPaymentUrl, isTrue);
      expect(order.needsPayment, isTrue);
      expect(order.amountDue, 80);
      expect(order.isDifferenceDue, isFalse);
      expect(order.payActionKey, 'pay_now');
      expect(order.statusLabelKey, 'status_pending_payment');
      expect(order.currentStage, OrderStage.pending);
    });

    test('PendingPayment بالرقم 14', () {
      expect(OrderStatusX.fromJson(14), OrderStatus.pendingPayment);
    });

    test('مدفوع من المحفظة: مفيش مستحق ولا لينك، والحالة ناجح', () {
      final order = OrderModel.fromJson({
        'id': 10,
        'status': 'New',
        'totalPrice': 50,
        'paymentMethod': 'Wallet',
        'amountPaid': 50,
        'outstandingAmount': 0,
        'paymentUrl': null,
        'paymentStatus': null,
        'isPaid': true,
      });

      expect(order.isPaid, isTrue);
      expect(order.needsPayment, isFalse);
      expect(order.hasPaymentUrl, isFalse);
      expect(order.paymentStatus, PaymentStatus.successful);
    });

    test('السعر زاد بعد المطابقة: ادفع الفرق، والدفع المبدئي لسه ناجح', () {
      final order = OrderModel.fromJson({
        'id': 11,
        'status': 'InProgress',
        'totalPrice': 60,
        'paymentMethod': 'Gateway',
        'amountPaid': 50,
        'outstandingAmount': 10,
        'paymentStatus': 'Successful',
        'isPaid': false,
      });

      expect(order.isPaid, isFalse);
      expect(order.needsPayment, isTrue);
      expect(order.amountDue, 10);
      expect(order.isDifferenceDue, isTrue);
      expect(order.payActionKey, 'pay_difference');
    });

    test('المرفوض والملغي مفيش عليهم دفع حتى لو فيه مبلغ', () {
      for (final status in ['Rejected', 'Cancelled']) {
        final order = OrderModel.fromJson({
          'id': 12,
          'status': status,
          'outstandingAmount': 40,
        });
        expect(order.needsPayment, isFalse, reason: status);
      }
    });

    test('الدفع المبدئي فشل: إعادة الدفع', () {
      final order = _order(
        status: OrderStatus.pendingPayment,
        paymentStatus: PaymentStatus.failed,
        remainingAmount: 125,
      );
      expect(order.payActionKey, 'retry_payment');
    });
  });

  group('OrderInvoicePdf', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUpAll(() async {
      await initializeDateFormatting('ar');
      final json = await File('assets/translations/ar.json').readAsString();
      Localization.load(
        const Locale('ar'),
        translations: Translations(jsonDecode(json) as Map<String, dynamic>),
      );
    });

    test('الـ PDF بيتعمل بالعربي بالقطع والحساب كله', () async {
      final invoice = OrderInvoice.fromOrder(
        _order(
          platformFee: 5,
          discount: 20,
          couponCode: 'SAVE20',
          paidAmount: 60,
          paymentStatus: PaymentStatus.pending,
          items: const [
            OrderItemModel(
              id: 1,
              name: 'قميص',
              quantity: 2,
              price: 5,
              total: 10,
            ),
            OrderItemModel(
              id: 2,
              name: 'Jacket',
              quantity: 1,
              price: 90,
              total: 90,
            ),
          ],
        ),
      );

      final bytes = await OrderInvoicePdf.build(invoice, locale: 'ar');

      expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
      // INVOICE_PDF_OUT=path بيحفظ الملف عشان نشوفه بعينينا
      final out = Platform.environment['INVOICE_PDF_OUT'];
      if (out != null) await File(out).writeAsBytes(bytes);
    });
  });
}
