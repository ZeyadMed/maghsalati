import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/order_pending/data/model/pending_order_model.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/order_details_card.dart';
import 'package:maghsalati/features/order_pending/presentation/view/widget/pending_status_header.dart';

/// شاشة انتظار موافقة المغسلة، بتتفتح بعد ما تدوس تأكيد الطلب
/// كل المحتوى في نص الشاشة، ولو الطلب طويل بيبقى قابل للسكرول
class OrederPending extends StatefulWidget {
  final PendingOrderModel order;

  const OrederPending({super.key, required this.order});

  @override
  State<OrederPending> createState() => _OrederPendingState();
}

class _OrederPendingState extends State<OrederPending> {
  /// مدة الانتظار قبل ما الشاشة تروح لشاشة قبول الطلب
  /// TODO: امسح التايمر ده لما رد المغسلة الحقيقي يجي من ال endpoint
  static const Duration _autoConfirmDelay = Duration(seconds: 30);

  Timer? _autoConfirmTimer;

  @override
  void initState() {
    super.initState();
    _autoConfirmTimer = Timer(_autoConfirmDelay, _goToConfirmOrder);
  }

  @override
  void dispose() {
    _autoConfirmTimer?.cancel();
    super.dispose();
  }

  /// بيروح لشاشة قبول الطلب، و pushReplacement عشان لو رجع مايرجعش للانتظار
  void _goToConfirmOrder() {
    if (!mounted) return;
    context.pushReplacement(AppRouter.confirmOrder, extra: widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              // المحتوى بيتوسط رأسيًا، ولو طول عن الشاشة بيسكرول عادي
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PendingStatusHeader(laundryName: widget.order.laundryName),
                    Gap(28.h),
                    OrderDetailsCard(order: widget.order),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
