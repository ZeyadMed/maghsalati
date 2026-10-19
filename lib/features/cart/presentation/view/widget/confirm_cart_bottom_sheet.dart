import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/router/app_router.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';
import 'package:maghsalati/features/cart/data/model/pickup_contact.dart';
import 'package:maghsalati/features/cart/presentation/view/widget/pickup_contact_card.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/cart/presentation/view_model/confirm_cart_cubit.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';
import 'package:maghsalati/features/profile/data/model/user_model.dart';
import 'package:maghsalati/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:maghsalati/features/saved_addresses/data/model/saved_address_model.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/address_type_icon.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view/widget/default_address_badge.dart';
import 'package:maghsalati/features/saved_addresses/presentation/view_model/saved_addresses_cubit.dart';

/// شيت بيانات الاستلام: العنوان الافتراضي (الطلب بيروح عليه بس ومابيتغيرش من هنا)
/// واسم ورقم اللي هيسلم الهدوم (صاحب الحساب جاهز، ويعدلهم لو حد تاني هيسلّم)،
/// وبيبعتهم على api/customer/cart/confirm قبل ما الطلب يتأكد
class ConfirmCartBottomSheet extends StatefulWidget {
  const ConfirmCartBottomSheet({super.key});

  /// بيرجع رقم الطلب لو اتأكد من السيرفر (0 لو الرقم مش معروف)،
  /// و null لو قفل الشيت من غير تأكيد
  static Future<int?> show(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ConfirmCartBottomSheet(),
    );
  }

  @override
  State<ConfirmCartBottomSheet> createState() => _ConfirmCartBottomSheetState();
}

class _ConfirmCartBottomSheetState extends State<ConfirmCartBottomSheet> {
  final ConfirmCartCubit _cubit = getIt<ConfirmCartCubit>();

  /// singleton في get_it فمش بيتعمله close هنا
  final SavedAddressesCubit _addresses = getIt<SavedAddressesCubit>();

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

  /// خطأ من الشيت نفسه قبل ما الريكوست يتبعت، زي إن العنوان مش متحدد
  String? _localError;

  @override
  void initState() {
    super.initState();
    // الافتراضي والاسم والرقم المحفوظين بيتعرضوا جاهزين، والاسم والرقم بس
    // اللي بيتعدلوا. الليستة وبيانات الحساب بيتحدثوا في الخلفية،
    // و _onAddressesLoaded و _onProfileResult بيمسكوا الجديد
    _addresses.load();
    _profile.getProfile();
  }

  @override
  void dispose() {
    _cubit.close();
    _profile.close();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// الليستة اتحدثت وفيها افتراضي (زي لما يضيف أول عنوان)، فغلط
  /// "أضف عنوان" مابقاش ليه لازمة
  void _onAddressesLoaded() {
    if (_localError == null || _addresses.defaultAddress == null) return;
    setState(() => _localError = null);
  }

  /// مفيش عناوين خالص، وأول عنوان بيتضاف السيرفر بيخليه الافتراضي،
  /// والفورم بيستنى الليستة تتحدث قبل ما يرجع فبيظهر على طول
  void _addAddress() => context.push<SavedAddressModel>(AppRouter.addressForm);

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

    final address = _addresses.defaultAddress;
    setState(() {
      _localError = address == null ? 'pickup_address_required'.tr() : null;
    });
    if (address == null) return;

    final contact = _editingContact
        ? PickupContact(name: _nameController.text, phone: _completePhone)
        : _owner;

    // الـ endpoint لسه بياخد العنوان والإحداثيات، فبنبعت قيم العنوان الافتراضي
    _cubit.confirm(
      ConfirmCartRequest(
        deliveryAddress: address.address,
        latitude: address.latitude,
        longitude: address.longitude,
        pickupContactName: contact.name.trim(),
        pickupContactPhoneNumber: contact.phone,
      ),
    );
  }

  /// السلة اتفضت على السيرفر، فبنفضي الكميات اللي على الموبايل ونحدث السلة
  /// ونبلّغ ليستة الطلبات إن فيه طلب جديد
  void _onConfirmed(int orderId) {
    getIt<SelectedServicesController>().clear();
    getIt<CartCubit>().getCart();
    getIt<OrderUpdates>().notify();
    Navigator.of(context).pop(orderId);
  }

  @override
  Widget build(BuildContext context) {
    // الخطأ بيتعرض جوه الشيت فوق الزرار، لأن السناك بار بيطلع تحت الشيت ومابيبانش
    return MultiBlocListener(
      listeners: [
        BlocListener<ConfirmCartCubit, BaseState<int>>(
          bloc: _cubit,
          listenWhen: (previous, current) => current.isSuccess,
          listener: (context, state) => _onConfirmed(state.data ?? 0),
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
      child: Padding(
        // الشيت بيطلع فوق الكيبورد عشان الخانات ماتستخباش
        padding: EdgeInsets.only(bottom: context.keyboardHeight),
        child: Container(
          constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                _buildHeader(),
                Divider(height: 1, color: AppColors.borderColor),
                Flexible(child: _buildForm()),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
      width: 44.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.greyColor5,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 8.w, 10.h),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 20.r,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text('pickup_details'.tr(), style: TextStyles.darkBold16),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(false),
            icon: Icon(Icons.close, size: 20.r, color: AppColors.greyColor2),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          Text('pickup_address'.tr(), style: TextStyles.darkBold14),
          SizedBox(height: 8.h),
          _buildAddressSection(),
          SizedBox(height: 16.h),
          _buildContactHeader(),
          SizedBox(height: 8.h),
          if (_editingContact)
            ..._buildContactFields()
          else
            PickupContactCard(
              contact: _owner,
              loadingPhone: _profile.state.isLoading,
              onEdit: _editContact,
            ),
          SizedBox(height: 12.h),
          _buildNote('final_price_note'.tr()),
        ],
      ),
    );
  }

  /// وهو بيعدل، زرار يرجعه لبياناته من غير ما يمسح الخانات بإيده
  Widget _buildContactHeader() {
    return Row(
      children: [
        Expanded(
          child: Text('pickup_contact'.tr(), style: TextStyles.darkBold14),
        ),
        if (_editingContact && _owner.isComplete)
          TextButton(
            onPressed: _useMyDetails,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size(0, 32.h),
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

  /// العنوان الافتراضي من غير تغيير، ولو مفيش عناوين زرار إضافة عنوان
  Widget _buildAddressSection() {
    return BlocBuilder<SavedAddressesCubit, BaseState<SavedAddressModel>>(
      bloc: _addresses,
      builder: (context, state) {
        final address = _addresses.defaultAddress;
        if (address != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDefaultAddress(address),
              SizedBox(height: 8.h),
              _buildNote('pickup_default_address_note'.tr()),
            ],
          );
        }
        // لسه بنجيب العناوين أول مرة، فمانقولش إن مفيش عناوين
        if (state.isLoading && !_addresses.hasLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }
        return OutlinedButton.icon(
          onPressed: _addAddress,
          icon: Icon(
            Icons.add_location_alt_outlined,
            size: 19.r,
            color: AppColors.primaryColor,
          ),
          label: Text(
            'add_pickup_address'.tr(),
            style: TextStyles.darkBold14.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            side: const BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      },
    );
  }

  /// عرض بس من غير زرار تغيير، لأن الطلب بيروح على الافتراضي بس
  Widget _buildDefaultAddress(SavedAddressModel address) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddressTypeIcon(address: address, highlighted: true),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.displayTitle,
                        style: TextStyles.darkBold14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const DefaultAddressBadge(),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  address.address,
                  style: TextStyles.darkRegular12.copyWith(
                    color: AppColors.greyColor2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (address.hasDetails) ...[
                  SizedBox(height: 2.h),
                  Text(
                    address.additionalDetails!.trim(),
                    style: TextStyles.darkRegular12.copyWith(
                      color: AppColors.greyColor3,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ملاحظة صغيرة بأيقونة، زي إن الإجمالي مبدئي (المغسلة بتعد القطع بعد
  /// ما توصلها وممكن تبعت تعديل، والدفع بيتطلب بعدها)
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

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: BlocBuilder<ConfirmCartCubit, BaseState<int>>(
        bloc: _cubit,
        builder: (context, state) {
          final error =
              _localError ??
              (state.isFailure ? state.errorMessage ?? 'try_again'.tr() : null);
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
              _buildButton(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButton(BaseState<int> state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          disabledBackgroundColor: AppColors.primaryColor.withValues(
            alpha: 0.6,
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
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
            : Text('confirm_order'.tr(), style: TextStyles.whiteBold15),
      ),
    );
  }
}
