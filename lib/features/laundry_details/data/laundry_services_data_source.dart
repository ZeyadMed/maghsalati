import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/laundry_details/data/model/service_category_model.dart';
import 'package:maghsalati/features/laundry_details/data/model/working_hours_model.dart';

abstract interface class LaundryServicesDataSource {
  Future<Either<Failure, List<ServiceCategoryModel>>> getServices(
    int laundryId,
  );

  Future<Either<Failure, WorkingHoursModel>> getWorkingHours(int laundryId);
}

class LaundryServicesDataSourceImpl implements LaundryServicesDataSource {
  final GenericDataSource _genericDataSource;
  LaundryServicesDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, List<ServiceCategoryModel>>> getServices(
    int laundryId,
  ) async {
    final result = await _genericDataSource.fetchData<ServiceCategoryModel>(
      endpoint: Endpoints.laundryServices(laundryId),
      fromJson: (json) => ServiceCategoryModel.fromJson(json),
    );
    return result;
  }

  @override
  Future<Either<Failure, WorkingHoursModel>> getWorkingHours(
    int laundryId,
  ) async {
    final result = await _genericDataSource.fetchResult<WorkingHoursModel>(
      endpoint: Endpoints.laundryWorkingHours(laundryId),
      fromJson: (json) => WorkingHoursModel.fromJson(json),
    );
    return result;
  }
}
