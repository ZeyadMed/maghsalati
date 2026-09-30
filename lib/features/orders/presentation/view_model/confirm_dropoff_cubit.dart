import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/notifications/data/notifications_data_source.dart';
import 'package:maghsalati/features/orders/data/orders_data_source.dart';

/// بتبعت الكود اللي المندوب إداه للعميل عشان الطلب يبقى Delivered
/// بتتعمل جديدة مع كل شيت تأكيد استلام
class ConfirmDropoffCubit extends Cubit<BaseState<void>> {
  final OrdersDataSource _ordersDataSource;
  final NotificationsDataSource _notificationsDataSource;

  ConfirmDropoffCubit(this._ordersDataSource, this._notificationsDataSource)
    : super(const BaseState<void>());

  /// [tripId] بييجي من تفاصيل الطلب أو من إشعار وصول المندوب، ولو مش معروف
  /// بندوّر عليه في إشعارات الطلب ده لأن شكل الرحلات في التفاصيل مش متوثق
  Future<void> confirm({
    required int orderId,
    required String otpCode,
    int? tripId,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    final resolvedTripId = tripId ?? await _tripIdFromNotifications(orderId);
    if (isClosed) return;
    if (resolvedTripId == null) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: 'dropoff_trip_unavailable'.tr(),
        ),
      );
      return;
    }

    final result = await _ordersDataSource.confirmDropoff(
      tripId: resolvedTripId,
      otpCode: otpCode,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (_) => emit(state.copyWith(status: Status.success)),
    );
  }

  /// أحدث إشعار للطلب ده فيه رقم رحلة، والطلب في التوصيل فهي رحلة التسليم
  Future<int?> _tripIdFromNotifications(int orderId) async {
    final result = await _notificationsDataSource.getNotifications(
      pageIndex: 1,
      pageSize: 20,
    );
    return result.fold(
      (_) => null,
      (page) => page.notifications
          .where((n) => n.orderId == orderId && n.deliveryTripId != null)
          .map((n) => n.deliveryTripId)
          .firstOrNull,
    );
  }
}
