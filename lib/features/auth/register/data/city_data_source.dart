import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/auth/register/models/city_model.dart';

abstract interface class CityDataSource {
  Future<Either<Failure, List<CityModel>>> getCities({String? search});
}

class CityDataSourceImpl implements CityDataSource {
  final GenericDataSource _genericDataSource;
  CityDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, List<CityModel>>> getCities({String? search}) async {
    final result = await _genericDataSource.fetchData<CityModel>(
      endpoint: Endpoints.cities,
      queryParameters: {'search': search},
      // الاند بوينت مفتوح، والتسجيل بيحصل قبل ما يبقى فيه توكن أصلاً
      headers: {'Authorization': null},
      fromJson: (json) => CityModel.fromJson(json),
    );
    return result;
  }
}
