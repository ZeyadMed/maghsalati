import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/notifications/data/model/notification_model.dart';
import 'package:maghsalati/features/notifications/data/notifications_data_source.dart';

/// بتجيب إشعارات المستخدم من api/laundry/notifications صفحة صفحة
/// وبتعلم كمقروء وتمسح. القراية والمسح بيبانوا على طول في الليستة،
/// ولو السيرفر رفض بترجع الليستة زي ما كانت وبترجع رسالة الخطأ للشاشة
class NotificationsCubit extends Cubit<BaseState<NotificationModel>> {
  final NotificationsDataSource _dataSource;

  static const int _pageSize = 10;

  /// لو اليوزر عمل refresh وفيه صفحة لسه بتحمل، نتيجتها القديمة بتتجاهل
  int _requestId = 0;

  NotificationsCubit(this._dataSource)
    : super(const BaseState<NotificationModel>());

  bool get hasUnread => state.items.any((n) => !n.isRead);

  /// أول صفحة، بتتنادى أول ما الشاشة تفتح ومع السحب للتحديث
  Future<void> getNotifications() async {
    final requestId = ++_requestId;
    // الإشعارات القديمة بتفضل ظاهرة لحد ما الجديدة توصل
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getNotifications(
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
          items: page.notifications,
          page: 2,
          hasReachedMax: page.isLastPage,
        ),
      ),
    );
  }

  /// الصفحة اللي بعدها، بتتنادى لما اليوزر يوصل لآخر الليستة
  Future<void> loadMore() async {
    if (state.hasReachedMax || state.isLoading || state.isLoadingMore) return;

    final requestId = _requestId;
    emit(state.copyWith(status: Status.isLoadingMore));

    final result = await _dataSource.getNotifications(
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
        // المسح بيزحزح الصفحات، فممكن إشعار يرجع تاني في الصفحة الجاية
        final loadedIds = state.items.map((n) => n.id).toSet();
        emit(
          state.copyWith(
            status: Status.success,
            items: [
              ...state.items,
              ...page.notifications.where((n) => !loadedIds.contains(n.id)),
            ],
            page: state.page + 1,
            hasReachedMax: page.isLastPage,
          ),
        );
      },
    );
  }

  /// بترجع رسالة الخطأ لو فشل، و null لو نجح أو كان مقروء أصلاً
  Future<String?> markAsRead(int notificationId) async {
    final target = state.items.where((n) => n.id == notificationId).firstOrNull;
    if (target == null || target.isRead) return null;

    return _optimistic(
      _updateItems(
        (n) => n.id == notificationId ? n.copyWith(isRead: true) : n,
      ),
      () => _dataSource.markAsRead(notificationId),
    );
  }

  Future<String?> markAllAsRead() async {
    if (!hasUnread) return null;

    return _optimistic(
      _updateItems((n) => n.copyWith(isRead: true)),
      _dataSource.markAllAsRead,
    );
  }

  Future<String?> deleteNotification(int notificationId) {
    return _optimistic(
      state.items.where((n) => n.id != notificationId).toList(),
      () => _dataSource.deleteNotification(notificationId),
    );
  }

  Future<String?> deleteAll() async {
    if (state.items.isEmpty) return null;

    return _optimistic(
      const [],
      _dataSource.deleteAll,
      // مفيش حاجة فاضلة في السيرفر نحملها
      hasReachedMax: true,
    );
  }

  List<NotificationModel> _updateItems(
    NotificationModel Function(NotificationModel) update,
  ) {
    return state.items.map(update).toList();
  }

  /// بتعرض [items] على طول وبعدين تبعت الطلب، ولو فشل بترجع الليستة القديمة
  /// إلا لو حصل refresh في النص، ساعتها الليستة الجديدة هي اللي بتفضل
  Future<String?> _optimistic(
    List<NotificationModel> items,
    Future<Either<Failure, void>> Function() request, {
    bool? hasReachedMax,
  }) async {
    final requestId = _requestId;
    final previous = state;
    emit(state.copyWith(items: items, hasReachedMax: hasReachedMax));

    final result = await request();

    return result.fold((failure) {
      if (!isClosed && requestId == _requestId) emit(previous);
      return failure.message;
    }, (_) => null);
  }
}
