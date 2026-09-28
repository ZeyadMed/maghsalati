import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_services_data_source.dart';

/// بتبعت قطعة واحدة بكميتها لسلة العميل على api/customer/cart
/// لما يدوس "أضف للسلة" في كارت القطعة.
/// الـ data في الستيت هي الـ id بتاع القطعة اللي الريكوست بتاعها شغال أو خلص،
/// عشان الكارت ده بس اللي يعرض اللودينج
class AddToCartCubit extends Cubit<BaseState<int>> {
  final LaundryServicesDataSource _dataSource;

  AddToCartCubit(this._dataSource) : super(const BaseState<int>());

  Future<void> addItem({required int itemId, required int quantity}) async {
    // ريكوست واحد في المرة عشان مايتبعتش نفس الطلب مرتين من دبل كليك
    if (state.isLoading || quantity <= 0) return;
    emit(state.copyWith(status: Status.loading, data: itemId));

    final result = await _dataSource.addToCart(
      laundryServiceItemId: itemId,
      quantity: quantity,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (_) => emit(state.copyWith(status: Status.success)),
    );
  }

  bool isAdding(int itemId) => state.isLoading && state.data == itemId;
}
