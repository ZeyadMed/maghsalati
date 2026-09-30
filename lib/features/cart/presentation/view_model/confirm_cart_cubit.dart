import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/cart/data/cart_data_source.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';

/// بتبعت بيانات الاستلام على api/customer/cart/confirm عشان السلة تتحول لطلب
/// بتتعمل جديدة مع كل شيت تأكيد وبتتقفل معاه
/// لما تنجح state.data بيبقى فيه رقم الطلب اللي اتعمل (0 لو مش معروف)
class ConfirmCartCubit extends Cubit<BaseState<int>> {
  final CartDataSource _dataSource;

  ConfirmCartCubit(this._dataSource) : super(const BaseState<int>());

  Future<void> confirm(ConfirmCartRequest request) async {
    // ريكوست واحد في المرة عشان الدبل كليك مايعملش طلبين
    if (state.isLoading) return;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.confirmCart(request);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (orderId) => emit(state.copyWith(status: Status.success, data: orderId)),
    );
  }
}
