import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/features/orders/data/model/order_invoice.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// بيعمل ملف PDF للفاتورة بلغة التطبيق: العربي من اليمين للشمال بخط Cairo
/// اللي في الأصول. نفس أسطر الحساب اللي في الشاشة ([OrderInvoice.lines])
abstract final class OrderInvoicePdf {
  static const _primary = PdfColor.fromInt(0xff3872E0);
  static const _primarySoft = PdfColor.fromInt(0xffF2F7FE);
  static const _dark = PdfColor.fromInt(0xff2C2C2C);
  static const _grey = PdfColor.fromInt(0xff808080);
  static const _border = PdfColor.fromInt(0xffE8EBE6);
  static const _green = PdfColor.fromInt(0xff16B364);
  static const _orange = PdfColor.fromInt(0xffFF6B00);
  static const _red = PdfColor.fromInt(0xffE11F1F);

  static Future<Uint8List> build(
    OrderInvoice invoice, {
    required String locale,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load(Assets.assetsFontsCairoRegular),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load(Assets.assetsFontsCairoBold),
    );
    final logo = pw.MemoryImage(
      (await rootBundle.load(Assets.assetsImagesLogoLight)).buffer
          .asUint8List(),
    );
    final isArabic = locale.startsWith('ar');

    final document = pw.Document(
      title: '${'invoice'.tr()} ${invoice.reference}',
      author: 'app_name'.tr(),
    );
    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(base: regular, bold: bold),
        ),
        footer: _buildFooter,
        build: (_) => [
          _buildHeader(invoice, logo),
          pw.SizedBox(height: 20),
          _buildInfo(invoice, locale),
          if (invoice.items.isNotEmpty) ...[
            pw.SizedBox(height: 22),
            _buildItems(invoice),
          ],
          pw.SizedBox(height: 22),
          _buildSummary(invoice),
        ],
      ),
    );
    return document.save();
  }

  /// العنوان وحالة الدفع على أول السطر واللوجو على آخره، وتحتهم خط بلون البراند
  static pw.Widget _buildHeader(OrderInvoice invoice, pw.ImageProvider logo) {
    final statusColor = invoice.isFullyPaid ? _green : _orange;
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'invoice'.tr(),
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _tint(statusColor),
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Text(
                      (invoice.isFullyPaid
                              ? 'payment_status_successful'
                              : 'payment_status_pending')
                          .tr(),
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Image(logo, height: 46),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Container(height: 2, color: _primary),
      ],
    );
  }

  /// اسم المغسلة ورقم الطلب والتاريخ وطريقة الدفع في أربع خانات جنب بعض
  static pw.Widget _buildInfo(OrderInvoice invoice, String locale) {
    // التاريخ بالأرقام بس: اسم الشهر العربي جنب السنة بيلزقوا في بعض في الـ PDF،
    // والأرقام إنجليزي زي المبالغ عشان ترتيبها مايتلخبطش
    final date = (DateFormat(
      'dd/MM/yyyy - h:mm a',
      locale,
    )..useNativeDigits = false).format(invoice.date);
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _primarySoft,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: _buildInfoCell('invoice_laundry_name', invoice.laundryName),
          ),
          pw.Expanded(
            flex: 2,
            child: _buildInfoCell('order_number', invoice.reference),
          ),
          pw.Expanded(flex: 3, child: _buildInfoCell('invoice_date', date)),
          pw.Expanded(
            flex: 2,
            child: _buildInfoCell(
              'payment_method',
              invoice.paymentMethodKey.tr(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoCell(String labelKey, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            labelKey.tr(),
            style: const pw.TextStyle(fontSize: 9, color: _grey),
          ),
          pw.SizedBox(height: 3),
          _buildDataText(
            value.isEmpty ? '-' : value,
            pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _dark,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// جدول القطع: الصنف والكمية وسعر الوحدة والإجمالي، بصفوف عادية عشان
  /// الأعمدة تمشي مع اتجاه اللغة
  static pw.Widget _buildItems(OrderInvoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'invoice_services_details'.tr(),
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: _dark,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildItemRow(
          name: 'invoice_item'.tr(),
          quantity: 'invoice_quantity'.tr(),
          unitPrice: 'invoice_unit_price'.tr(),
          total: 'total'.tr(),
          isHeader: true,
        ),
        for (final item in invoice.items)
          _buildItemRow(
            name: item.name,
            quantity: '${item.quantity}',
            unitPrice: _money(item.price),
            total: _money(item.total),
          ),
      ],
    );
  }

  static pw.Widget _buildItemRow({
    required String name,
    required String quantity,
    required String unitPrice,
    required String total,
    bool isHeader = false,
  }) {
    final style = isHeader
        ? pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _primary,
          )
        : const pw.TextStyle(fontSize: 10, color: _dark);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: isHeader
          ? pw.BoxDecoration(
              color: _primarySoft,
              borderRadius: pw.BorderRadius.circular(6),
            )
          : const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _border)),
            ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 5, child: _buildDataText(name, style)),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              quantity,
              style: style,
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              unitPrice,
              style: style,
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(total, style: style, textAlign: pw.TextAlign.end),
          ),
        ],
      ),
    );
  }

  /// الحساب بالترتيب المطلوب في صندوق على آخر الصفحة، والإجمالي النهائي
  /// في شريط بلون البراند. خط رفيع بيفصل الرسوم والخصم عن المدفوع والباقي
  static pw.Widget _buildSummary(OrderInvoice invoice) {
    final rows = <pw.Widget>[];
    InvoiceLine? previous;
    for (final line in invoice.lines) {
      final startsPayments =
          line.kind == InvoiceLineKind.paid &&
          previous?.kind != InvoiceLineKind.paid;
      if (startsPayments) {
        rows.add(pw.Divider(color: _border, height: 14, thickness: 1));
      }
      rows.add(
        line.kind == InvoiceLineKind.total
            ? _buildTotalRow(line)
            : _buildSummaryRow(line),
      );
      previous = line;
    }

    return pw.Row(
      children: [
        pw.Spacer(flex: 2),
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _border),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: rows,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(InvoiceLine line) {
    final color = switch (line.kind) {
      _ when line.amount == 0 => _dark,
      InvoiceLineKind.discount => _red,
      InvoiceLineKind.paid => _green,
      InvoiceLineKind.remaining => _orange,
      _ => _dark,
    };
    final label = line.note.isEmpty
        ? line.labelKey.tr()
        : '${line.labelKey.tr()} (${line.note})';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10.5, color: _grey),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            _lineAmount(line),
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(InvoiceLine line) {
    final style = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(line.labelKey.tr(), style: style)),
          pw.Text(_money(line.amount), style: style),
        ],
      ),
    );
  }

  /// نص جاي من السيرفر (اسم المغسلة أو القطعة) ممكن يبقى عربي والفاتورة
  /// إنجليزي، والـ pdf مابيوصّلش الحروف العربي غير في اتجاه rtl، فاتجاهه
  /// بيتحدد من محتواه ومحاذاته بتفضل على أول السطر بتاع الصفحة
  static pw.Widget _buildDataText(
    String text,
    pw.TextStyle style, {
    int? maxLines,
  }) {
    return pw.Builder(
      builder: (context) {
        final pageIsRtl = pw.Directionality.of(context) == pw.TextDirection.rtl;
        return pw.Text(
          text,
          style: style,
          maxLines: maxLines,
          textDirection: _arabicLetters.hasMatch(text)
              ? pw.TextDirection.rtl
              : null,
          textAlign: pageIsRtl ? pw.TextAlign.right : pw.TextAlign.left,
        );
      },
    );
  }

  static final _arabicLetters = RegExp(r'[؀-ۿݐ-ݿ]');

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: _border, thickness: 1),
        pw.Text(
          'invoice_thanks'.tr(args: ['app_name'.tr()]),
          style: const pw.TextStyle(fontSize: 9, color: _grey),
          textAlign: pw.TextAlign.center,
        ),
        if (context.pagesCount > 1)
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _grey),
          ),
      ],
    );
  }

  /// الخصم بيتعرض بالسالب لو فيه خصم فعلًا
  static String _lineAmount(InvoiceLine line) =>
      line.kind == InvoiceLineKind.discount && line.amount > 0
      ? '- ${_money(line.amount)}'
      : _money(line.amount);

  static String _money(num amount) =>
      '${formatOrderPrice(amount)} ${'currency'.tr()}';

  /// نفس اللون بشفافية خفيفة على أبيض، زي شارات التطبيق
  static PdfColor _tint(PdfColor color) => PdfColor(
    1 - (1 - color.red) * 0.12,
    1 - (1 - color.green) * 0.12,
    1 - (1 - color.blue) * 0.12,
  );
}
