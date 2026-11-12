import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/cart/data/model/cart_model.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';
import 'package:maghsalati/features/cart/data/model/pickup_contact.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_item_tile.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/cart_price.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/checkout_address_card.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/checkout_expandable_card.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/checkout_invoice_card.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/pickup_contact_card.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/cart/presentation/view_model/confirm_cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_status_style.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';
import 'package:maghsalati/features/wallet/presentation/view/widget/payment_method_selector.dart';
import 'package:maghsalati/features/wallet/presentation/view_model/wallet_balance_cubit.dart';

/// تفاصيل الطلب قبل التأكيد، نفس الشكل في تاب السلة وفي شيت التأكيد:
/// 1. خريطة عليها dropdown بالعناوين المحفوظة: العنوان بيتغير للطلب ده بس،
///    والسيرفر بيحسب عليه التوصيل ويقول المغسلة بتوصّل له ولا لأ
/// 2. ملخص الطلب: اسم المغسلة، ولما يتفتح القطع بكمياتها
/// 3. طريقة الدفع: المحفظة برصيدها أو البوابة
/// 4. بيانات اللي هيسلّم الهدوم (صاحب الحساب جاهز، ويعدلها للطلب ده بس)
/// 5. الفاتورة: سعر القطع والتوصيل (استلام + تسليم) والإجمالي
/// وتحت زرار التأكيد بالإجمالي، وبيبعت كله على api/customer/cart/confirm
class CheckoutForm extends StatefulWidget {
  /// آخر نسخة من السلة، والشاشة اللي فوق بتبنيه من جديد مع كل تحديث
  final CartModel cart;

  /// الطلب اتأكد من السيرفر، ومعاه السلة زي ما كانت وقت التأكيد
  final void Function(OrderModel order, CartModel cart) onConfirmed;

  /// في تاب السلة بياخد الشاشة كلها والزرار تحت خالص،
  /// وفي الشيت بياخد طول محتواه بس
  final bool fillHeight;

  const CheckoutForm({
    super.key,
    required this.cart,
    required this.onConfirmed,
    this.fillHeight = false,
  });

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  final ConfirmCartCubit _cubit = getIt<ConfirmCartCubit>();

  /// singleton في get_it فمش بيتعمله close هنا
  final SavedAddressesCubit _addresses = getIt<SavedAddressesCubit>();

  /// singleton في get_it فمش بيتعمله close هنا
  final CartCubit _cartCubit = getIt<CartCubit>();

  /// singleton في get_it فمش بيتعمله close هنا
  final WalletBalanceCubit _wallet = getIt<WalletBalanceCubit>();

  /// بيانات الحساب، بتجيب الرقم لأنه مابيرجعش مع اللوجين
  final ProfileCubit _profile = getIt<ProfileCubit>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  /// صاحب الحساب، بيتعرض جاهز وبيتبعت هو لو ماعدلش
  PickupContact _owner = PickupContact.cachedOwner();

  /// حد تاني هيسلّم الهدوم، فالاسم والرقم بيتكتبوا في الخانات للطلب ده بس
  /// من غير ما بيانات الحساب تتغير
  bool _editingContact = false;

  /// الرقم كامل بكود الدولة، بيتحدث من [CustomPhoneField] مع كل كتابة
  String _completePhone = '';

  /// خطأ من الفورم نفسه قبل ما الريكوست يتبعت، زي إن العنوان مش متحدد
  String? _localError;

  /// null لحد ما العميل يختار، والافتراضي من [PaymentMethodSelector.effectiveMethod]
  PaymentMethod? _paymentMethod;

  bool _summaryExpanded = false;
  bool _paymentExpanded = false;

  /// السلة بتتحسب على العنوان اللي لسه مختاره
  bool _switchingAddress = false;

  /// سعر التوصيل اتغير بعد تغيير العنوان، فبنقول للعميل القديم والجديد
  String? _feeChangeNote;

  /// العنوان اللي الطلب رايح له: اللي اختاره للطلب ده، أو الافتراضي
  SavedAddressModel? get _selectedAddress =>
      _addresses.addressOrDefault(_cartCubit.deliveryAddressId);

  /// السبب لو المغسلة مش بتوصّل للعنوان، و null لو بتوصّل
  String? get _undeliverableMessage {
    final cart = widget.cart;
    if (cart.isDeliverable) return null;
    if (cart.undeliverableReason != null) return cart.undeliverableReason;
    final maxKm = cart.maxDeliveryDistanceKm;
    return maxKm == null
        ? 'address_out_of_range'.tr()
        : 'address_out_of_range_km'.tr(args: [formatCartPrice(maxKm)]);
  }

  num get _total => widget.cart.totalPrice;

  @override
  void initState() {
    super.initState();
    // الافتراضي والاسم والرقم المحفوظين بيتعرضوا جاهزين، والليستة وبيانات
    // الحساب والرصيد بيتحدثوا في الخلفية
    _addresses.load();
    _profile.getProfile();
    _wallet.load();
    // بعد أول فريم عشان التحميل بيعمل emit والشاشة اللي فوق لسه بتتبني
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncCartAddress();
    });
  }

  /// السلة لازم تبقى محسوبة على العنوان اللي الطلب رايح له. ممكن تكون اتجابت
  /// قبل ما العناوين توصل (فالسيرفر حسبها على موقع البروفايل) أو قبل ما
  /// الافتراضي يتغير، فبنقارن deliveryAddressId اللي رجع بالمطلوب
  void _syncCartAddress() {
    final wanted = _selectedAddress?.id;
    if (wanted == null || _cartCubit.state.isLoading || _switchingAddress) {
      return;
    }
    if (widget.cart.deliveryAddressId != wanted) _cartCubit.getCart();
  }

  @override
  void dispose() {
    _cubit.close();
    _profile.close();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// الليستة اتحدثت. لو العنوان المختار للطلب اتمسح بنرجع للافتراضي، وغير
  /// كده بنتأكد إن السلة محسوبة على العنوان الصح ([_syncCartAddress]).
  /// وغلط "أضف عنوان" مابقاش ليه لازمة لو بقى فيه عنوان
  void _onAddressesLoaded() {
    final chosenId = _cartCubit.deliveryAddressId;
    final chosenGone =
        chosenId != null &&
        !_addresses.state.items.any((address) => address.id == chosenId);

    if (chosenGone) {
      _cartCubit.selectDeliveryAddress(null);
    } else {
      _syncCartAddress();
    }

    if (_localError == null || _selectedAddress == null) return;
    setState(() => _localError = null);
  }

  /// العنوان بيتغير للطلب ده بس، والسلة بتتجاب محسوبة عليه. لو سعر التوصيل
  /// اتغير بنعرض القديم والجديد، ولو المغسلة مش بتوصّل الكارت بيعرض التنبيه
  Future<void> _selectAddress(SavedAddressModel address) async {
    if (address.id == _selectedAddress?.id) return;
    final oldFees = widget.cart.deliveryFees;
    setState(() {
      _switchingAddress = true;
      _feeChangeNote = null;
      _localError = null;
    });

    await _cartCubit.selectDeliveryAddress(address.id);
    if (!mounted) return;

    final cart = _cartCubit.state.data;
    setState(() {
      _switchingAddress = false;
      if (_cartCubit.state.isSuccess &&
          cart != null &&
          cart.isDeliverable &&
          cart.deliveryFees != oldFees) {
        _feeChangeNote = 'delivery_fee_changed'.tr(
          args: [_money(oldFees), _money(cart.deliveryFees)],
        );
      }
    });
  }

  /// العنوان الجديد بيتختار للطلب على طول. أول عنوان السيرفر بيخليه
  /// الافتراضي، والفورم بيستنى الليستة تتحدث قبل ما يرجع
  Future<void> _addAddress() async {
    final added = await context.push<SavedAddressModel>(AppRouter.addressForm);
    if (added == null || !mounted) return;
    await _selectAddress(added);
  }

  String _money(num value) => '${formatCartPrice(value)} ${'currency'.tr()}';

  /// السيرفر رفض التأكيد ومااتعملش طلب: 409 الإجمالي اتغير، أو 400 العنوان
  /// برا النطاق. بنجيب السلة على نفس العنوان عشان يشوف الجديد قبل ما يأكد تاني
  void _onConfirmFailed() {
    if (_cubit.shouldRefreshCart) _cartCubit.getCart();
  }

  /// بيانات الحساب وصلت (أو فشلت): صاحب الحساب بياخد الاسم والرقم الجداد،
  /// ولو لسه ناقصه حاجة بنفتح الخانات يكتبها بنفسه
  void _onProfileResult(UserModel? user) {
    setState(() {
      if (user != null) {
        _owner = _owner.merge(name: user.name, phone: user.phoneNumber);
      }
      if (!_owner.isComplete && !_editingContact) _fillContactFields();
    });
  }

  /// الخانات بتبدأ ببيانات صاحب الحساب، فيغير الاسم أو الرقم اللي محتاجه بس
  void _fillContactFields() {
    _nameController.text = _owner.name;
    _phoneController.text = _owner.nationalNumber;
    _completePhone = _owner.phone;
    _editingContact = true;
  }

  void _editContact() => setState(_fillContactFields);

  /// يرجع لصاحب الحساب ويسيب اللي كتبه للطلب ده
  void _useMyDetails() => setState(() => _editingContact = false);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // بيانات الحساب لسه ماوصلتش ومفيش رقم محفوظ، فبنفتح الخانات يكتبه
    if (!_editingContact && !_owner.isComplete) {
      setState(_fillContactFields);
      return;
    }

    final address = _selectedAddress;
    setState(() {
      _localError = address == null ? 'pickup_address_required'.tr() : null;
    });
    if (address == null) return;

    final contact = _editingContact
        ? PickupContact(name: _nameController.text, phone: _completePhone)
        : _owner;

    // الباك الجديد بيعتمد على savedAddressId ويعيد الحساب، والعنوان والإحداثيات
    // لسه بيتبعتوا للباك القديم
    _cubit.confirm(
      ConfirmCartRequest(
        savedAddressId: address.id,
        expectedTotal: _total,
        deliveryAddress: address.address,
        latitude: address.latitude,
        longitude: address.longitude,
        pickupContactName: contact.name.trim(),
        pickupContactPhoneNumber: contact.phone,
        paymentMethod: PaymentMethodSelector.effectiveMethod(
          _paymentMethod,
          _total,
        ),
      ),
    );
  }

  /// السلة اتفضت على السيرفر، فبنفضي الكميات اللي على الموبايل ونحدث السلة
  /// ونبلّغ ليستة الطلبات إن فيه طلب جديد، ولو اتدفع من المحفظة نحدث الرصيد
  void _onConfirmed(OrderModel order) {
    final cart = widget.cart;
    getIt<SelectedServicesController>().clear();
    // الطلب الجاي يبدأ على العنوان الافتراضي
    _cartCubit.resetDeliveryAddress();
    _cartCubit.getCart();
    getIt<OrderUpdates>().notify();
    if (order.paymentMethod == PaymentMethod.wallet || order.isPaid) {
      _wallet.load();
    }
    widget.onConfirmed(order, cart);
  }

  @override
  Widget build(BuildContext context) {
    final form = _buildForm();
    // الخطأ بيتعرض فوق الزرار، لأن السناك بار بيطلع تحت الشيت ومابيبانش
    return MultiBlocListener(
      listeners: [
        BlocListener<ConfirmCartCubit, BaseState<OrderModel>>(
          bloc: _cubit,
          listenWhen: (previous, current) => current.isSuccess,
          listener: (context, state) => _onConfirmed(state.data!),
        ),
        BlocListener<ConfirmCartCubit, BaseState<OrderModel>>(
          bloc: _cubit,
          listenWhen: (previous, current) => current.isFailure,
          listener: (context, state) => _onConfirmFailed(),
        ),
        BlocListener<SavedAddressesCubit, BaseState<SavedAddressModel>>(
          bloc: _addresses,
          listenWhen: (previous, current) => current.isSuccess,
          listener: (context, state) => _onAddressesLoaded(),
        ),
        BlocListener<ProfileCubit, BaseState<UserModel>>(
          bloc: _profile,
          listenWhen: (previous, current) =>
              current.isSuccess || current.isFailure,
          listener: (context, state) => _onProfileResult(state.data),
        ),
      ],
      child: Column(
        mainAxisSize: widget.fillHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (widget.fillHeight)
            Expanded(child: form)
          else
            Flexible(child: form),
          _buildSubmitBar(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: !widget.fillHeight,
        // عشان السحب للتحديث يشتغل في تاب السلة
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          CheckoutAddressCard(
            addresses: _addresses,
            selectedId: _cartCubit.deliveryAddressId,
            busy: _switchingAddress,
            warning: _undeliverableMessage,
            onSelect: _selectAddress,
            onAddAddress: _addAddress,
          ),
          _buildSectionTitle('order_summary'.tr()),
          _buildSummaryCard(),
          _buildSectionTitle('payment_method'.tr()),
          _buildPaymentCard(),
          _buildContactHeader(),
          if (_editingContact)
            ..._buildContactFields()
          else
            PickupContactCard(
              contact: _owner,
              loadingPhone: _profile.state.isLoading,
              onEdit: _editContact,
            ),
          _buildSectionTitle('invoice'.tr()),
          CheckoutInvoiceCard(cart: widget.cart),
          if (_feeChangeNote != null) ...[
            SizedBox(height: 10.h),
            _buildFeeChangeNote(_feeChangeNote!),
          ],
          SizedBox(height: 12.h),
          _buildNote('final_price_note'.tr()),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
      child: Text(title, style: TextStyles.darkBold16),
    );
  }

  /// اسم المغسلة وعدد القطع، ولما يتفتح القطع بكاونتر الكمية والمسح
  Widget _buildSummaryCard() {
    final cart = widget.cart;
    return CheckoutExpandableCard(
      icon: Icons.local_laundry_service_outlined,
      title: cart.laundryName,
      subtitle: 'cart_pieces_count'.plural(cart.totalPieces),
      expanded: _summaryExpanded,
      onToggle: () => setState(() => _summaryExpanded = !_summaryExpanded),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < cart.items.length; i++) ...[
            if (i > 0) Divider(height: 20.h, color: AppColors.borderColor),
            CartItemTile(
              item: cart.items[i],
              isUpdating: _cartCubit.isUpdating(cart.items[i]),
              onQuantityChanged: (quantity) =>
                  _cartCubit.updateQuantity(cart.items[i], quantity),
              onRemove: () => _cartCubit.removeItem(cart.items[i]),
            ),
          ],
        ],
      ),
    );
  }

  /// مقفول بيعرض الطريقة المختارة، ومفتوح بيعرض الاختيار. ولو المحفظة
  /// مش كفاية بيفضل مفتوح عشان تنبيه الرصيد وزرار الشحن يبانوا
  Widget _buildPaymentCard() {
    return BlocBuilder<WalletBalanceCubit, BaseState<num>>(
      bloc: _wallet,
      builder: (context, state) {
        final method = PaymentMethodSelector.effectiveMethod(
          _paymentMethod,
          _total,
        );
        final short = PaymentMethodSelector.isWalletShort(
          _paymentMethod,
          _total,
        );
        return CheckoutExpandableCard(
          icon: method.icon,
          title: method.labelKey.tr(),
          subtitle: short
              ? 'wallet_insufficient_balance'.tr()
              : _methodSubtitle(method, state),
          subtitleColor: short ? AppColors.redColor2 : null,
          expanded: _paymentExpanded || short,
          onToggle: () => setState(() => _paymentExpanded = !_paymentExpanded),
          child: PaymentMethodSelector(
            selected: _paymentMethod,
            amount: _total,
            // بيتقفل بعد الاختيار، إلا لو المحفظة مش كفاية
            onChanged: (method) => setState(() {
              _paymentMethod = method;
              _paymentExpanded = false;
            }),
          ),
        );
      },
    );
  }

  String _methodSubtitle(PaymentMethod method, BaseState<num> state) {
    if (method == PaymentMethod.gateway) {
      return 'payment_method_gateway_hint'.tr();
    }
    final balance = state.data;
    if (balance == null) return 'wallet_balance_loading'.tr();
    return 'wallet_available_balance'.tr(
      args: ['${formatOrderPrice(balance)} ${'currency'.tr()}'],
    );
  }

  /// وهو بيعدل، زرار يرجعه لبياناته من غير ما يمسح الخانات بإيده
  Widget _buildContactHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text('pickup_contact'.tr(), style: TextStyles.darkBold16),
          ),
          if (_editingContact && _owner.isComplete)
            TextButton(
              onPressed: _useMyDetails,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                minimumSize: Size(0, 28.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'use_my_details'.tr(),
                style: TextStyles.darkBold14.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// اسم ورقم حد تاني للطلب ده بس، والعنوان بيفضل زي ما هو
  List<Widget> _buildContactFields() {
    return [
      _buildNote('pickup_contact_edit_note'.tr()),
      SizedBox(height: 10.h),
      Customtextfield(
        labelText: 'pickup_contact_name',
        style: TextStyles.darkBold14,
        textEditingController: _nameController,
        hintText: 'pickup_contact_name_hint',
        keyboardType: TextInputType.name,
        prefix: const Icon(Icons.person_outline),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? 'nameMustBeNotEmpty'.tr()
            : null,
      ),
      SizedBox(height: 12.h),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 6),
        child: Text('phone_number'.tr(), style: TextStyles.darkBold14),
      ),
      SizedBox(height: 8.h),
      CustomPhoneField(
        controller: _phoneController,
        // الرقم بيتبعت بكود الدولة زي التسجيل
        onChanged: (phone) => _completePhone = phone.completeNumber,
        validator: (value) => (value == null || value.trim().isEmpty)
            ? 'phoneNumberEmpty'.tr()
            : null,
      ),
    ];
  }

  /// سعر التوصيل اتغير بعد تغيير العنوان
  Widget _buildFeeChangeNote(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.orangeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 18.r,
            color: AppColors.orangeColor,
          ),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: TextStyles.darkRegular12)),
        ],
      ),
    );
  }

  /// ملاحظة صغيرة بأيقونة، زي إن الإجمالي مبدئي (المغسلة بتعد القطع بعد
  /// ما توصلها: لو زاد العميل يدفع الفرق، ولو قلّ الفرق يرجع لمحفظته)
  Widget _buildNote(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16.r, color: AppColors.primaryColor),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyles.greyColor2Regular14.copyWith(fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: BlocBuilder<ConfirmCartCubit, BaseState<OrderModel>>(
        bloc: _cubit,
        builder: (context, state) {
          final error =
              _localError ??
              (_cubit.pricesChanged ? 'cart_prices_updated'.tr() : null) ??
              (state.isFailure
                  ? state.errorMessage ?? 'try_again'.tr()
                  : null) ??
              (widget.cart.isDeliverable ? null : 'address_out_of_range'.tr());
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null) ...[
                Text(
                  error,
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.redColor2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
              ],
              // الرصيد بيتحدث من الشحن جوه الاختيار، فالزرار بيتبني معاه
              BlocBuilder<WalletBalanceCubit, BaseState<num>>(
                bloc: _wallet,
                builder: (context, _) => _buildButton(state),
              ),
            ],
          );
        },
      ),
    );
  }

  /// المحفظة متختارة ورصيدها معروف إنه مش كفاية، فالزرار مقفول لحد ما
  /// يشحن أو يختار البوابة (التنبيه وزرار الشحن في كارت طريقة الدفع).
  /// وكمان مقفول والسلة بتتحدث عشان الإجمالي اللي عليه يبقى الأخير
  Widget _buildButton(BaseState<OrderModel> state) {
    final walletShort = PaymentMethodSelector.isWalletShort(
      _paymentMethod,
      _total,
    );
    final cartRefreshing = _cartCubit.state.isLoading || _switchingAddress;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            state.isLoading ||
                walletShort ||
                cartRefreshing ||
                !widget.cart.isDeliverable
            ? null
            : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          disabledBackgroundColor: AppColors.primaryColor.withValues(
            alpha: 0.6,
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          shape: const StadiumBorder(),
        ),
        child: state.isLoading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.whiteColor,
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      'confirm_order'.tr(),
                      style: TextStyles.whiteBold15,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    '${formatCartPrice(_total)} ${'currency'.tr()}',
                    style: TextStyles.whiteBold15,
                  ),
                ],
              ),
      ),
    );
  }
}
