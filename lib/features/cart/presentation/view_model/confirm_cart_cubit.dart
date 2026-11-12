import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/cart/data/cart_data_source.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';

/// بتبعت بيانات الاستلام وطريقة الدفع على api/customer/cart/confirm عشان
/// السلة تتحول لطلب. بتتعمل جديدة مع كل شيت تأكيد وبتتقفل معاه
/// لما تنجح state.data بيبقى فيه الطلب اللي اتعمل
class ConfirmCartCubit extends Cubit<BaseState<OrderModel>> {
  final CartDataSource _dataSource;

  /// مفتاح في الـ metadata بيشيل status code بتاع الفشل
  static const String _statusKey = 'statusCode';

  ConfirmCartCubit(this._dataSource) : super(const BaseState<OrderModel>());

  Future<void> confirm(ConfirmCartRequest request) async {
    // ريكوست واحد في المرة عشان الدبل كليك مايعملش طلبين
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading, metadata: {}));

    final result = await _dataSource.confirmCart(request);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          metadata: {_statusKey: failure.statusCode},
        ),
      ),
      (order) => emit(state.copyWith(status: Status.success, data: order)),
    );
  }

  /// السيرفر حسب إجمالي غير اللي العميل شافه (409) ومااتعملش طلب،
  /// فالسلة لازم تتحدث قبل ما يأكد تاني
  bool get pricesChanged =>
      state.isFailure && state.metadata[_statusKey] == 409;

  /// 400 غالبًا العنوان طلع برا نطاق المغسلة، و409 الإجمالي اتغير: في
  /// الحالتين السلة لازم تتحدث عشان التنبيه أو الإجمالي الجديد يبان
  bool get shouldRefreshCart =>
      state.isFailure &&
      (state.metadata[_statusKey] == 400 || state.metadata[_statusKey] == 409);
}
