import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/cart/data/cart_data_source.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/data/laundry_services_data_source.dart';

/// كل دوسة على قطعة في الجريد بتزود منها واحدة في سلة العميل على api/customer/cart
/// الدوسات بتتجمع وبيتبعت ريكوست واحد في المرة: القطعة لو مش في السلة
/// بتتضاف بـ POST، ولو موجودة كميتها بتتعدل بـ PUT، عشان مانعتمدش على
/// إن الإضافة بتجمع على الكمية القديمة
///
/// الـ data في الستيت = الدوسات اللي لسه ماظهرتش في سلة السيرفر لكل قطعة
/// (itemId -> العدد)، فالرقم اللي على القطعة = كميتها في السلة + الرقم ده
/// وبيزيد مع الدوسة على طول من غير ما يستنى السيرفر.
/// والستيت loading طول ما فيه دوسات بتتبعت
class AddToCartCubit extends Cubit<BaseState<Map<int, int>>> {
  final LaundryServicesDataSource _servicesDataSource;
  final CartDataSource _cartDataSource;

  /// singleton، منها بنعرف القطعة في السلة ولا لأ وبتتحدث بعد كل ريكوست
  final CartCubit _cartCubit;

  /// دوسات لسه مااتبعتتش
  final Map<int, int> _queued = {};

  /// دوسات اتبعتت ومستنية السلة تتجاب تاني عشان تظهر فيها
  final Map<int, int> _sent = {};

  bool _syncing = false;

  AddToCartCubit(
    this._servicesDataSource,
    this._cartDataSource,
    this._cartCubit,
  ) : super(const BaseState<Map<int, int>>(data: <int, int>{}));

  /// فيه دوسات لسه بتتبعت، فالسلة على السيرفر لسه مش آخر حاجة
  bool get isSyncing => state.isLoading;

  void addOne(int itemId) {
    _queued[itemId] = (_queued[itemId] ?? 0) + 1;
    _emitPending(Status.loading);
    _sync();
  }

  /// الـ loop بيكمل حتى لو الشاشة اتقفلت عشان كل دوسة توصل السيرفر،
  /// والـ emit بس هو اللي بيقف
  Future<void> _sync() async {
    if (_syncing) return;
    _syncing = true;

    while (_queued.isNotEmpty) {
      final itemId = _queued.keys.first;
      final count = _queued.remove(itemId)!;
      _sent[itemId] = (_sent[itemId] ?? 0) + count;

      final result = await _send(itemId, count);
      if (result.isError) {
        _fail(result.throwError().message);
        break;
      }

      // الدوسات بتفضل محسوبة لحد ما السلة الجديدة توصل عشان الرقم مايرجعش لورا
      await _cartCubit.getCart();
      // من غير سلة جديدة مش هنعرف الكمية الصح، فالدوسة الجاية ممكن تبعت رقم غلط
      if (_cartCubit.state.isFailure) {
        _fail(_cartCubit.state.errorMessage);
        break;
      }

      _sent.remove(itemId);
      _emitPending(_queued.isEmpty ? Status.success : Status.loading);
    }

    _syncing = false;
  }

  /// القطعة لو في السلة بنزود كميتها، ولو مش فيها بنضيفها بعدد الدوسات
  Future<Either<Failure, void>> _send(int itemId, int count) {
    final line = _cartCubit.state.data?.lineOf(itemId);
    if (line == null) {
      return _servicesDataSource.addToCart(
        laundryServiceItemId: itemId,
        quantity: count,
      );
    }
    // الـ cartItemId هو الـ id بتاع السطر في السلة، مش laundryServiceItemId
    return _cartDataSource.updateQuantity(
      cartItemId: line.id,
      quantity: line.quantity + count,
    );
  }

  /// غالبًا النت أو السيرفر فالباقي هيقع هو كمان، فبنلغي الدوسات كلها
  /// والأرقام بترجع لسلة السيرفر
  void _fail(String? message) {
    _queued.clear();
    _sent.clear();
    _emitPending(Status.failure, errorMessage: message);
  }

  void _emitPending(Status status, {String? errorMessage}) {
    if (isClosed) return;
    final pending = <int, int>{..._sent};
    _queued.forEach((id, count) => pending[id] = (pending[id] ?? 0) + count);
    emit(
      state.copyWith(
        status: status,
        data: pending,
        errorMessage: errorMessage,
      ),
    );
  }
}
