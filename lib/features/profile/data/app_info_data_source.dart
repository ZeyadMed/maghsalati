import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/endpoints.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/profile/data/model/contact_info_model.dart';
import 'package:maghsalati/features/profile/data/model/privacy_policy_model.dart';

/// بيانات التطبيق اللي بتتغير من لوحة التحكم: التواصل وسياسة الخصوصية
abstract interface class AppInfoDataSource {
  Future<Either<Failure, ContactInfoModel>> getContacts();

  Future<Either<Failure, PrivacyPolicyModel>> getPrivacyPolicy();
}

class AppInfoDataSourceImpl implements AppInfoDataSource {
  final GenericDataSource _genericDataSource;
  AppInfoDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, ContactInfoModel>> getContacts() {
    return _genericDataSource.fetchResult<ContactInfoModel>(
      endpoint: Endpoints.contacts,
      fromJson: ContactInfoModel.fromJson,
    );
  }

  @override
  Future<Either<Failure, PrivacyPolicyModel>> getPrivacyPolicy() {
    return _genericDataSource.fetchResult<PrivacyPolicyModel>(
      endpoint: Endpoints.privacyPolicy,
      fromJson: PrivacyPolicyModel.fromJson,
    );
  }
}
