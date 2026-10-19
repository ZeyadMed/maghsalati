import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/core/helpers/generic_data_source.dart';
import 'package:maghsalati/core/http/api_consumer.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/features/profile/data/model/profile_image_rules.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/data/profile_data_source.dart';

/// بيمسك الطلب اللي خارج ويرد بالـ JSON اللي في [responseBody]
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? request;
  Map<String, dynamic> responseBody = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    await requestStream?.drain<void>();
    return ResponseBody.fromString(
      jsonEncode(responseBody),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _user = UserModel(
  id: 7,
  name: 'أحمد',
  phoneNumber: '+218911234567',
  address: 'طرابلس، شارع عمر المختار',
  cityId: 3,
  cityName: 'طرابلس',
  latitude: 32.88,
  longitude: 13.19,
  phoneNumberConfirmed: true,
  createdAt: null,
  imageUrl: 'https://cdn.example.com/old.jpg',
);

Map<String, dynamic> _profileJson({String imageUrl = ''}) => {
  'id': 7,
  'name': 'أحمد',
  'phoneNumber': '+218911234567',
  'address': 'طرابلس، شارع عمر المختار',
  'cityId': 3,
  'cityName': 'طرابلس',
  'latitude': 32.88,
  'longitude': 13.19,
  'phoneNumberConfirmed': true,
  'imageUrl': imageUrl,
};

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('profile_test'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  File writeFile(String name, int bytes) =>
      File('${tempDir.path}/$name')..writeAsBytesSync(Uint8List(bytes));

  group('ProfileImageRules', () {
    test('بيقبل الامتدادات اللي الباك بيقبلها بأي حالة حروف', () {
      for (final name in ['a.jpg', 'a.JPEG', 'a.png', 'a.gif', 'a.webp']) {
        expect(ProfileImageRules.validate(writeFile(name, 10)), isNull);
      }
    });

    test('بيرفض HEIC والملفات من غير امتداد', () {
      expect(
        ProfileImageRules.validate(writeFile('a.heic', 10)),
        'image_type_not_supported',
      );
      expect(
        ProfileImageRules.validate(writeFile('image', 10)),
        'image_type_not_supported',
      );
    });

    test('الحد الأقصى 5MB بالظبط', () {
      const max = ProfileImageRules.maxSizeInBytes;
      expect(ProfileImageRules.validate(writeFile('ok.jpg', max)), isNull);
      expect(
        ProfileImageRules.validate(writeFile('big.jpg', max + 1)),
        'image_too_large',
      );
    });
  });

  group('ProfileDataSource.updateProfile', () {
    late _CapturingAdapter adapter;
    late ProfileDataSource dataSource;

    setUp(() {
      adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
        ..httpClientAdapter = adapter;
      dataSource = ProfileDataSourceImpl(
        GenericDataSource(BaseApiConsumer(dio: dio)),
      );
    });

    test('بيبعت PUT multipart بالحقول ومن غير Image لو مفيش صورة جديدة', () async {
      adapter.responseBody = {
        'data': _profileJson(imageUrl: 'https://cdn.example.com/old.jpg'),
      };

      final result = await dataSource.updateProfile(_user);

      final request = adapter.request!;
      expect(request.method, 'PUT');
      expect(request.path, contains('api/customer/profile'));
      expect(
        request.headers[Headers.contentTypeHeader],
        startsWith('multipart/form-data'),
      );

      final form = request.data as FormData;
      expect(Map.fromEntries(form.fields), {
        'Name': 'أحمد',
        'Address': 'طرابلس، شارع عمر المختار',
        'CityId': '3',
        'Latitude': '32.88',
        'Longitude': '13.19',
      });
      expect(form.files, isEmpty);

      expect(result.isError, isFalse);
      expect(result.getOrThrow().imageUrl, 'https://cdn.example.com/old.jpg');
    });

    test('بيبعت الصورة في Image وبيرجع imageUrl الجديد', () async {
      adapter.responseBody = _profileJson(
        imageUrl: 'https://cdn.example.com/new.jpg',
      );

      final result = await dataSource.updateProfile(
        _user,
        image: writeFile('photo.jpg', 100),
      );

      final form = adapter.request!.data as FormData;
      expect(form.files.single.key, 'Image');
      expect(form.files.single.value.filename, 'photo.jpg');

      // الرد ممكن ييجي في الروت من غير data
      expect(result.getOrThrow().imageUrl, 'https://cdn.example.com/new.jpg');
      expect(result.getOrThrow().name, 'أحمد');
    });
  });
}
