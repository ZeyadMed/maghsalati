import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

/// بتجهز لينك الدفع قبل ما صفحة MyFatoorah تتفتح، و state.data فيه اللينك
/// لو الطلب معاه لينك ولسه مافشلش بيتستخدم زي ما هو، غير كده بنطلب لينك جديد
/// من retry-payment، ولو الرد مافيهوش لينك بنجيبه من تفاصيل الطلب
class PaymentLinkCubit extends Cubit<BaseState<String>> {
  final OrdersDataSource _dataSource;

  PaymentLinkCubit(this._dataSource) : super(const BaseState<String>());

  Future<void> prepare(OrderModel order) async {
    if (state.isLoading) return;

    // lastUpdated بيتغير كل مرة عشان لو نفس اللينك رجع تاني الستيت تبقى جديدة
    // والشاشة تفتح صفحة الدفع تاني
    if (order.hasPaymentUrl && order.paymentStatus != PaymentStatus.failed) {
      emit(
        state.copyWith(
          status: Status.success,
          data: order.paymentUrl,
          lastUpdated: DateTime.now(),
        ),
      );
      return;
    }

    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.retryPayment(order.id);
    if (isClosed) return;
    if (result.isError) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: result.throwError().message,
        ),
      );
      return;
    }

    var url = result.getOrThrow();
    if (url == null) {
      final details = await _dataSource.getOrderDetails(order.id);
      if (isClosed) return;
      url = details.fold(
        (_) => null,
        (fresh) => fresh.hasPaymentUrl ? fresh.paymentUrl : null,
      );
    }

    emit(
      url == null
          ? state.copyWith(
              status: Status.failure,
              errorMessage: 'payment_link_unavailable'.tr(),
            )
          : state.copyWith(
              status: Status.success,
              data: url,
              lastUpdated: DateTime.now(),
            ),
    );
  }
}
