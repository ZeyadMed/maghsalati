import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/wallet/data/model/wallet_transaction_model.dart';
import 'package:maghsalati/features/wallet/data/wallet_data_source.dart';

/// حركات المحفظة من api/customer/wallet/transactions صفحة صفحة،
/// نفس طريقة ليستة الإشعارات
class WalletTransactionsCubit extends Cubit<BaseState<WalletTransactionModel>> {
  final WalletDataSource _dataSource;

  static const int _pageSize = 15;

  /// لو اليوزر عمل refresh وفيه صفحة لسه بتحمل، نتيجتها القديمة بتتجاهل
  int _requestId = 0;

  WalletTransactionsCubit(this._dataSource)
    : super(const BaseState<WalletTransactionModel>());

  /// أول صفحة، أول ما الشاشة تفتح ومع السحب للتحديث وبعد الشحن
  Future<void> load() async {
    final requestId = ++_requestId;
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getTransactions(
      pageIndex: 1,
      pageSize: _pageSize,
    );

    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          status: Status.success,
          items: page.transactions,
          page: 2,
          hasReachedMax: page.isLastPage,
        ),
      ),
    );
  }

  /// الصفحة اللي بعدها، لما اليوزر يوصل لآخر الليستة
  Future<void> loadMore() async {
    if (state.hasReachedMax || state.isLoading || state.isLoadingMore) return;

    final requestId = _requestId;
    emit(state.copyWith(status: Status.isLoadingMore));

    final result = await _dataSource.getTransactions(
      pageIndex: state.page,
      pageSize: _pageSize,
    );

    if (isClosed || requestId != _requestId) return;

    result.fold(
      // الليستة بتفضل زي ما هي، ولما يعمل سكرول تاني بيحاول تاني
      (failure) => emit(
        state.copyWith(
          status: Status.isLoadingMoreFauilare,
          errorMessage: failure.message,
        ),
      ),
      (page) {
        // حركة جديدة بتزحزح الصفحات، فممكن حركة ترجع تاني في الصفحة الجاية
        final loadedIds = state.items.map((t) => t.id).toSet();
        emit(
          state.copyWith(
            status: Status.success,
            items: [
              ...state.items,
              ...page.transactions.where((t) => !loadedIds.contains(t.id)),
            ],
            page: state.page + 1,
            hasReachedMax: page.isLastPage,
          ),
        );
      },
    );
  }
}
