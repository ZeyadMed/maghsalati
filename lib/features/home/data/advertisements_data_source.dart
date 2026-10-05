import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/home/data/model/advertisement_model.dart';

abstract interface class AdvertisementsDataSource {
  Future<Either<Failure, List<AdvertisementModel>>> getAdvertisements();
}

class AdvertisementsDataSourceImpl implements AdvertisementsDataSource {
  final GenericDataSource _genericDataSource;
  AdvertisementsDataSourceImpl(this._genericDataSource);

  /// الإعلانات متقسمة حسب نوع الأبلكيشن،
  /// وده أبلكيشن العميل فبنطلب Customer دايماً
  static const _targetType = 'Customer';

  @override
  Future<Either<Failure, List<AdvertisementModel>>> getAdvertisements() {
    return _genericDataSource.fetchData<AdvertisementModel>(
      endpoint: Endpoints.advertisements,
      queryParameters: {'targetType': _targetType},
      fromJson: AdvertisementModel.fromJson,
    );
  }
}
