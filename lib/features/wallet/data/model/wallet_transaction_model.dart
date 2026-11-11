import 'package:maghsalati/core/helpers/json_reader.dart';

/// حركة في محفظة العميل (WalletTransactionDto)
class WalletTransactionModel {
  final int id;

  /// موجب = إضافة (شحن أو استرجاع فرق)، سالب = خصم (دفع طلب)
  final num amount;

  /// نوع الحركة نص عربي جاهز من السيرفر: "شحن رصيد" | "دفع طلب" | "استرجاع فرق طلب"
  final String type;
  final int? orderId;
  final String description;
  final DateTime? createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.amount,
    this.type = '',
    this.orderId,
    this.description = '',
    this.createdAt,
  });

  bool get isCredit => amount >= 0;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final orderId = json.pickInt(['orderId']);
    return WalletTransactionModel(
      id: json.pickInt(['id']) ?? 0,
      amount: json.pickNum(['amount']) ?? 0,
      type: json.pickString(['type']),
      orderId: orderId != null && orderId > 0 ? orderId : null,
      description: json.pickString(['description']).trim(),
      createdAt: DateTime.tryParse(json.pickString(['createdAt'])),
    );
  }
}

/// صفحة من حركات المحفظة، الـ API بيرجعها جوه data ومعاها بيانات الصفحات
class WalletTransactionsPageModel {
  final int pageIndex;
  final int totalPages;
  final List<WalletTransactionModel> transactions;

  const WalletTransactionsPageModel({
    required this.pageIndex,
    required this.totalPages,
    required this.transactions,
  });

  bool get isLastPage => pageIndex >= totalPages;

  factory WalletTransactionsPageModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsPageModel(
      pageIndex: json.pickInt(['pageIndex']) ?? 1,
      totalPages: json.pickInt(['totalPages']) ?? 1,
      transactions: json
          .pickList(['data', 'items'])
          .map(WalletTransactionModel.fromJson)
          .toList(),
    );
  }
}

/// رد شحن المحفظة بكود (RedeemRechargeCodeResultDto)
class RechargeResultModel {
  /// قيمة الكود اللي اتضافت
  final num amount;
  final num newBalance;

  const RechargeResultModel({required this.amount, required this.newBalance});

  /// postData بترجع الريسبونس كله والنتيجة جوه data
  factory RechargeResultModel.fromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final json = data is Map<String, dynamic> ? data : response;
    final newBalance = json.pickNum(['newBalance', 'balance']);
    if (newBalance == null) {
      throw const FormatException('Redeem response has no newBalance');
    }
    return RechargeResultModel(
      amount: json.pickNum(['amount']) ?? 0,
      newBalance: newBalance,
    );
  }
}
