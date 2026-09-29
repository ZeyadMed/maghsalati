import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/notifications/data/model/notification_model.dart';

abstract interface class NotificationsDataSource {
  Future<Either<Failure, NotificationsPageModel>> getNotifications({
    required int pageIndex,
    required int pageSize,
  });

  Future<Either<Failure, void>> markAsRead(int notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(int notificationId);

  Future<Either<Failure, void>> deleteAll();
}

class NotificationsDataSourceImpl implements NotificationsDataSource {
  final GenericDataSource _genericDataSource;
  NotificationsDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, NotificationsPageModel>> getNotifications({
    required int pageIndex,
    required int pageSize,
  }) {
    // fetchResult بتبعت اللي جوه data للموديل، وفيه الإشعارات وبيانات الصفحات
    return _genericDataSource.fetchResult<NotificationsPageModel>(
      endpoint: Endpoints.notifications,
      queryParameters: {'PageIndex': pageIndex, 'PageSize': pageSize},
      fromJson: NotificationsPageModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    final result = await _genericDataSource.updateData<Null>(
      endpoint: Endpoints.readNotification(notificationId),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    final result = await _genericDataSource.updateData<Null>(
      endpoint: Endpoints.readAllNotifications,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    final result = await _genericDataSource.deleteData<Null>(
      endpoint: Endpoints.notification(notificationId),
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> deleteAll() async {
    final result = await _genericDataSource.deleteData<Null>(
      endpoint: Endpoints.notifications,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
