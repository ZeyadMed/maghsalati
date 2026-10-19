import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/api_consumer.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/features/profile/data/app_info_data_source.dart';
import 'package:maghsalati/features/profile/data/model/page_content_model.dart';

/// بيرد على أي GET بنفس شكل الباك ويسجل المسارات اللي اتطلبت
class _ContentAdapter implements HttpClientAdapter {
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.uri.path);
    return ResponseBody.fromString(
      jsonEncode({
        'statusCode': 200,
        'message': 'تم الجلب بنجاح.',
        'data': {
          'content': '<h1>${options.uri.path}</h1><p>نص</p>',
          'updatedAt': '2026-01-01T00:00:00',
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('كل صفحة بتنادي الاند بوينت بتاعتها وبتفك content و updatedAt', () async {
    final adapter = _ContentAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
      ..httpClientAdapter = adapter;
    final dataSource = AppInfoDataSourceImpl(
      GenericDataSource(BaseApiConsumer(dio: dio)),
    );

    const expected = {
      ContentPage.privacyPolicy: '/api/auth/privacy-policy',
      ContentPage.scopeOfService: '/api/auth/scope-of-service',
      ContentPage.serviceProvider: '/api/auth/service-provider',
    };

    for (final MapEntry(key: page, value: path) in expected.entries) {
      final result = await dataSource.getPageContent(page);
      final content = result.getOrThrow();

      expect(adapter.paths.last, path);
      expect(content.content, '<h1>$path</h1><p>نص</p>');
      expect(content.updatedAt, DateTime(2026));
    }
  });

  test('عنوان نطاق الخدمة ومقدم الخدمة نفس أسماء اختصارات المغسلة', () {
    expect(ContentPage.privacyPolicy.titleKey, 'privacy_policy');
    expect(ContentPage.scopeOfService.titleKey, 'service_area');
    expect(ContentPage.serviceProvider.titleKey, 'service_provider');
  });
}
