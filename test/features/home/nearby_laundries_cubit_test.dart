import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/home/data/model/nearby_laundry_model.dart';
import 'package:maghsalati/features/home/data/nearby_laundries_data_source.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/home/presentation/view_model/nearby_laundries_cubit.dart';

/// الباك بيحسب isAvailableNow وقت الطلب، فالسيرفر الوهمي بيرجع اللي متحدد فيه دلوقتي
class _FakeServer implements NearbyLaundriesDataSource {
  bool isAvailableNow = true;
  bool fails = false;
  int calls = 0;

  @override
  Future<Either<Failure, List<NearbyLaundryModel>>> getNearbyLaundries({
    double? lat,
    double? lng,
    String? search,
  }) async {
    calls++;
    if (fails) return Left(ServerFailure(message: 'offline'));
    return Right([
      NearbyLaundryModel.fromJson({
        'id': 1,
        'name': 'مغسلة',
        'isAvailableNow': isAvailableNow,
      }),
    ]);
  }
}

/// موقع جاهز من الأول عشان الـ cubit يجيب على طول
class _ReadyLocation extends ChangeNotifier implements LocationController {
  @override
  bool get isLoading => false;

  @override
  double? get latitude => 32.88;

  @override
  double? get longitude => 13.19;

  @override
  Future<void> load() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeServer server;
  late NearbyLaundriesCubit cubit;

  setUp(() async {
    server = _FakeServer();
    cubit = NearbyLaundriesCubit(server, _ReadyLocation())..start();
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => cubit.close());

  test('refresh picks up a laundry that just closed without a loading flash',
      () async {
    expect(cubit.state.items.single.isAvailableNow, isTrue);

    final statuses = <Status>[];
    final sub = cubit.stream.listen((state) => statuses.add(state.status));
    server.isAvailableNow = false;
    await cubit.refresh();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(statuses, [Status.success]);
    expect(cubit.state.items.single.isAvailableNow, isFalse);
  });

  test('a failed refresh keeps the current list', () async {
    server.fails = true;
    await cubit.refresh();

    expect(cubit.state.isSuccess, isTrue);
    expect(cubit.state.items, hasLength(1));
  });

  test('refresh after a failed load retries with loading', () async {
    server.fails = true;
    await cubit.getLaundries();
    expect(cubit.state.isFailure, isTrue);

    server.fails = false;
    await cubit.refresh();
    expect(cubit.state.isSuccess, isTrue);
    expect(server.calls, 3);
  });
}
