import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/features/orders/data/model/order_invoice.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/order_invoice_pdf.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_sheet_frame.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:printing/printing.dart';

/// فاتورة الطلب المكتمل: بتتفتح من تفاصيل الطلب لما يبقى Delivered بس.
/// فوق اسم المغسلة ورقم الطلب والتاريخ وطريقة الدفع، وتحت القطع والحساب
/// بالترتيب اللي في [OrderInvoice.lines]. التحميل بيفتح حفظ الملفات بتاع
/// الجهاز، والمشاركة من فوق بتفتح شيت المشاركة بنفس الـ PDF
class OrderInvoiceScreen extends StatefulWidget {
  final OrderModel order;

  const OrderInvoiceScreen({super.key, required this.order});

  @override
  State<OrderInvoiceScreen> createState() => _OrderInvoiceScreenState();
}

class _OrderInvoiceScreenState extends State<OrderInvoiceScreen> {
  late final OrderInvoice _invoice = OrderInvoice.fromOrder(widget.order);

  /// الـ PDF بيتعمل مرة واحدة ويتستخدم للتحميل والمشاركة
  Uint8List? _pdf;
  bool _isSaving = false;
  bool _isSharing = false;

  Future<Uint8List> _pdfBytes() async => _pdf ??= await OrderInvoicePdf.build(
    _invoice,
    locale: context.locale.toString(),
  );

  /// المستخدم بيختار مكان الملف، ولو قفل الشاشة من غير حفظ مفيش رسالة
  Future<void> _download() async {
    setState(() => _isSaving = true);
    try {
      final bytes = await _pdfBytes();
      final savedPath = await FilePicker.platform.saveFile(
        fileName: _invoice.fileName,
        bytes: bytes,
      );
      if (savedPath != null && mounted) {
        context.showSuccessMessage('invoice_saved'.tr());
      }
    } catch (_) {
      if (mounted) context.showErrorMessage('invoice_failed'.tr());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// [buttonContext] عشان شيت المشاركة يطلع من الزرار على الآيباد
  Future<void> _share(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final bounds = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _isSharing = true);
    try {
      await Printing.sharePdf(
        bytes: await _pdfBytes(),
        filename: _invoice.fileName,
        bounds: bounds,
      );
    } catch (_) {
      if (mounted) context.showErrorMessage('invoice_failed'.tr());
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: CustomAppBar(
        title: 'invoice',
        backgroundColor: AppColors.secondaryColor,
        actions: [
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: 'share_invoice'.tr(),
              onPressed: _isSharing ? null : () => _share(buttonContext),
              icon: Icon(Icons.ios_share_rounded, size: 22.r),
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: _buildPaper(context),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: SheetButton(
            label: 'download_invoice_pdf'.tr(),
            isLoading: _isSaving,
            onPressed: _download,
          ),
        ),
      ),
    );
  }

  /// الفاتورة نفسها في كارت أبيض شبه الورقة اللي في الـ PDF
  Widget _buildPaper(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Gap(14.h),
          Container(height: 2.h, color: AppColors.primaryColor),
          Gap(16.h),
          _buildInfo(context),
          if (_invoice.items.isNotEmpty) ...[Gap(20.h), _buildItems()],
          Gap(20.h),
          ..._buildSummary(),
          Gap(18.h),
          Text(
            'invoice_thanks'.tr(args: ['app_name'.tr()]),
            style: TextStyles.darkRegular12.copyWith(
              color: AppColors.greyColor3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// كلمة "فاتورة" وتحتها حالة الدفع، واللوجو على الجنب التاني
  Widget _buildHeader() {
    final paid = _invoice.isFullyPaid;
    final statusColor = paid ? AppColors.greenColor : AppColors.orangeColor;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'invoice'.tr(),
                style: TextStyles.blueBold20.copyWith(fontSize: 22.sp),
              ),
              Gap(4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  (paid
                          ? 'payment_status_successful'
                          : 'payment_status_pending')
                      .tr(),
                  style: TextStyles.darkBold12.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(12.w),
        Image.asset(Assets.assetsImagesLogoLight, height: 40.h),
      ],
    );
  }

  /// اسم المغسلة ورقم الطلب والتاريخ وطريقة الدفع في مربع فاتح
  Widget _buildInfo(BuildContext context) {
    final date = DateFormat(
      'd MMMM yyyy - h:mm a',
      context.locale.toString(),
    ).format(_invoice.date);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoCell(
                  'invoice_laundry_name',
                  _invoice.laundryName,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: _buildInfoCell(
                  'order_number',
                  _invoice.reference,
                  onCopy: () => _copyReference(context),
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoCell('invoice_date', date)),
              Gap(12.w),
              Expanded(
                child: _buildInfoCell(
                  'payment_method',
                  _invoice.paymentMethodKey.tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyReference(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _invoice.reference));
    if (context.mounted) context.showSuccessMessage('copied'.tr());
  }

  Widget _buildInfoCell(String labelKey, String value, {VoidCallback? onCopy}) {
    final valueText = Text(
      value.isEmpty ? '-' : value,
      style: TextStyles.darkBold14,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelKey.tr(),
          style: TextStyles.darkRegular12.copyWith(color: AppColors.greyColor3),
        ),
        Gap(2.h),
        if (onCopy == null)
          valueText
        else
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: valueText),
                Gap(4.w),
                Icon(
                  Icons.copy_outlined,
                  size: 14.r,
                  color: AppColors.greyColor3,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// القطع اللي اتحاسب عليها: الاسم وتحته الكمية × سعر القطعة، والإجمالي جنبه
  Widget _buildItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'invoice_services_details'.tr(),
          style: TextStyles.darkBold16.copyWith(fontWeight: FontWeight.w700),
        ),
        Gap(8.h),
        for (int i = 0; i < _invoice.items.length; i++) ...[
          if (i > 0) Divider(height: 16.h, color: AppColors.lightGreyColor),
          _buildItemRow(_invoice.items[i]),
        ],
      ],
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyles.darkRegular14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${item.quantity} × ${_money(item.price)}',
                style: TextStyles.darkRegular12.copyWith(
                  color: AppColors.greyColor3,
                ),
              ),
            ],
          ),
        ),
        Gap(12.w),
        Text(_money(item.total), style: TextStyles.darkBold14),
      ],
    );
  }

  /// أسطر الحساب بالترتيب المطلوب، وخط بيفصل الرسوم والخصم عن المدفوع والباقي
  /// والإجمالي النهائي في شريط بلون البراند
  List<Widget> _buildSummary() {
    final lines = _invoice.lines;
    return [
      Divider(height: 1.h, color: AppColors.lightGreyColor),
      Gap(12.h),
      for (int i = 0; i < lines.length; i++) ...[
        if (i > 0 &&
            lines[i].kind == InvoiceLineKind.paid &&
            lines[i - 1].kind != InvoiceLineKind.paid)
          Divider(height: 20.h, color: AppColors.lightGreyColor),
        if (lines[i].kind == InvoiceLineKind.total)
          _buildTotalRow(lines[i])
        else
          _buildSummaryRow(lines[i]),
      ],
    ];
  }

  Widget _buildSummaryRow(InvoiceLine line) {
    final color = switch (line.kind) {
      _ when line.amount == 0 => AppColors.darkTextColor,
      InvoiceLineKind.discount => AppColors.redColor2,
      InvoiceLineKind.paid => AppColors.greenColor,
      InvoiceLineKind.remaining => AppColors.orangeColor,
      _ => AppColors.darkTextColor,
    };
    final amount = _money(line.amount);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: line.labelKey.tr(),
                children: [
                  if (line.note.isNotEmpty)
                    TextSpan(
                      text: ' (${line.note})',
                      style: TextStyle(color: AppColors.greyColor3),
                    ),
                ],
              ),
              style: TextStyles.darkRegular14.copyWith(
                color: AppColors.greyColor2,
              ),
            ),
          ),
          Gap(12.w),
          Text(
            line.kind == InvoiceLineKind.discount && line.amount > 0
                ? '- $amount'
                : amount,
            style: TextStyles.darkBold14.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(InvoiceLine line) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.labelKey.tr(),
              style: TextStyles.whiteBold15.copyWith(fontSize: 16.sp),
            ),
          ),
          Gap(12.w),
          Text(
            _money(line.amount),
            style: TextStyles.whiteBold15.copyWith(fontSize: 18.sp),
          ),
        ],
      ),
    );
  }

  String _money(num amount) => '${formatOrderPrice(amount)} ${'currency'.tr()}';
}
