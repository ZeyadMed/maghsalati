import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/http/either.dart';
import 'package:maghsalati/core/http/failure.dart';
import 'package:maghsalati/features/cart/data/cart_data_source.dart';
import 'package:maghsalati/features/cart/data/model/cart_item_model.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';

/// بتجيب سلة العميل من api/customer/cart وبتعدل كميات القطع فيها وبتمسحها
/// singleton في get_it عشان شيت السلة وتاب السلة يقروا من نفس الستيت،
/// وأي إضافة للسلة بتحدثها فالاتنين يشوفوا الجديد
class CartCubit extends Cubit<BaseState<CartModel>> {
  final CartDataSource _dataSource;

  /// مفتاح في الـ metadata بيشيل id السطر اللي كميته بتتعدل أو بيتمسح دلوقتي
  static const String _updatingKey = 'updatingItemId';

  /// مفتاح في الـ metadata بيتحط وقت مسح السلة كلها
  static const String _clearingKey = 'clearing';

  CartCubit(this._dataSource) : super(const BaseState<CartModel>());

  Future<void> getCart() async {
    // لو فيه سلة قديمة بتفضل ظاهرة لحد ما الجديدة توصل بدل ما الشاشة تفضى
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getCart();

    if (isClosed) return;

    result.fold(
      // الـ metadata بتتمسح في الحالتين عشان لودينج الكاونتر مايعلقش
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          metadata: {},
        ),
      ),
      (data) => emit(
        state.copyWith(status: Status.success, data: data, metadata: {}),
      ),
    );
  }

  /// السطر ده كميته بتتعدل، فالكاونتر بتاعه بيعرض لودينج
  bool isUpdating(CartItemModel item) =>
      state.metadata[_updatingKey] == item.id;

  /// السلة كلها بتتمسح دلوقتي، فزرار المسح بيعرض لودينج
  bool get isClearing => state.metadata.containsKey(_clearingKey);

  /// أي تعديل شغال دلوقتي، فمانبعتش تاني لحد ما يخلص
  bool get _isBusy => state.metadata.containsKey(_updatingKey) || isClearing;

  /// بتبعت الكمية الجديدة على PUT api/customer/cart/{cartItemId}
  /// وبعدين بتجيب السلة تاني عشان الإجماليات والرسوم بتتحسب من السيرفر
  Future<void> updateQuantity(CartItemModel item, int quantity) async {
    // تعديل واحد في المرة عشان الدوسات السريعة ماتبعتش كميات متلخبطة،
    // وأقل كمية 1 فالـ - عند 1 مابيبعتش حاجة
    if (_isBusy || quantity < 1) return;
    emit(state.copyWith(metadata: {_updatingKey: item.id}));

    final result = await _dataSource.updateQuantity(
      // الـ cartItemId هو الـ id بتاع السطر في السلة، مش laundryServiceItemId
      cartItemId: item.id,
      quantity: quantity,
    );

    await _refreshAfter(result);
  }

  /// بتشيل السطر ده من السلة على DELETE api/customer/cart/{cartItemId}
  Future<void> removeItem(CartItemModel item) async {
    if (_isBusy) return;
    emit(state.copyWith(metadata: {_updatingKey: item.id}));

    final result = await _dataSource.removeItem(item.id);

    await _refreshAfter(result);
  }

  /// بتمسح السلة كلها على DELETE api/customer/cart
  Future<void> clearCart() async {
    if (_isBusy) return;
    emit(state.copyWith(metadata: {_clearingKey: true}));

    final result = await _dataSource.clearCart();

    await _refreshAfter(result);
  }

  /// بعد أي تعديل: لو وقع بيعرض الخطأ، ولو نجح بيجيب السلة من السيرفر تاني
  Future<void> _refreshAfter(Either<Failure, void> result) async {
    if (isClosed) return;

    if (result.isError) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: result.throwError().message,
          metadata: {},
        ),
      );
      return;
    }

    await getCart();
  }
}
