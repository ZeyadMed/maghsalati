import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/home/data/model/nearby_laundry_model.dart';

abstract interface class NearbyLaundriesDataSource {
  Future<Either<Failure, List<NearbyLaundryModel>>> getNearbyLaundries({
    double? lat,
    double? lng,
    String? search,
  });
}

class NearbyLaundriesDataSourceImpl implements NearbyLaundriesDataSource {
  final GenericDataSource _genericDataSource;
  NearbyLaundriesDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, List<NearbyLaundryModel>>> getNearbyLaundries({
    double? lat,
    double? lng,
    String? search,
  }) async {
    final result = await _genericDataSource.fetchData<NearbyLaundryModel>(
      endpoint: Endpoints.nearbyLaundries,
      // الـ null والفاضي بيتشالوا في fetchData، فلو الموقع مش متاح
      // الطلب بيروح من غير إحداثيات والباك بيرجع المغاسل عادي
      queryParameters: {'lat': lat, 'lng': lng, 'search': search},
      fromJson: (json) => NearbyLaundryModel.fromJson(json),
    );
    return result;
  }
}
