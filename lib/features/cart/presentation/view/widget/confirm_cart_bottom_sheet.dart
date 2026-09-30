import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/core/cache_manager/cache_manager.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/service_locator/service_locator.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/custom_phone_field.dart';
import 'package:maghsalati/core/widget/custom_text_field.dart';
import 'package:maghsalati/features/auth/register/presentation/view/widget/location_picker_field.dart';
import 'package:maghsalati/features/cart/data/model/confirm_cart_request.dart';
import 'package:maghsalati/features/cart/presentation/view_model/cart_cubit.dart';
import 'package:maghsalati/features/cart/presentation/view_model/confirm_cart_cubit.dart';
import 'package:maghsalati/features/home/presentation/view_model/location_controller.dart';
import 'package:maghsalati/features/laundry_details/presentation/view_model/selected_services_controller.dart';
import 'package:maghsalati/features/orders/presentation/view_model/order_updates.dart';

/// شيت بيانات الاستلام: العنوان والموقع واسم ورقم اللي هيسلم الهدوم،
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
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  double? _latitude;
  double? _longitude;

  /// الرقم كامل بكود الدولة، بيتحدث من [CustomPhoneField] مع كل كتابة
  String _completePhone = '';

  /// خطأ من الشيت نفسه قبل ما الريكوست يتبعت، زي إن الموقع مش متحدد
  String? _localError;

  @override
  void initState() {
    super.initState();
    // الموقع اللي الهوم جابته والاسم المحفوظ بيتحطوا جاهزين، ويقدر يعدلهم
    final location = getIt<LocationController>();
    if (location.hasAddress) {
      _addressController.text = location.address;
      _latitude = location.latitude;
      _longitude = location.longitude;
    }
    _nameController.text = CacheManager.getUserName() ?? '';
  }

  @override
  void dispose() {
    _cubit.close();
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // الإحداثيات بتيجي من الـ GPS بس، فلو العنوان اتكتب بإيده لازم يحدد موقعه
    final missingLocation = _latitude == null || _longitude == null;
    setState(() {
      _localError = missingLocation ? 'pickup_location_required'.tr() : null;
    });
    if (missingLocation) return;

    _cubit.confirm(
      ConfirmCartRequest(
        deliveryAddress: _addressController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        pickupContactName: _nameController.text.trim(),
        pickupContactPhoneNumber: _completePhone,
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
    return BlocListener<ConfirmCartCubit, BaseState<int>>(
      bloc: _cubit,
      listenWhen: (previous, current) => current.isSuccess,
      listener: (context, state) => _onConfirmed(state.data ?? 0),
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
          Text('address'.tr(), style: TextStyles.darkBold14),
          SizedBox(height: 4.h),
          LocationPickerField(
            controller: _addressController,
            onLocationPicked: (latitude, longitude) {
              _latitude = latitude;
              _longitude = longitude;
            },
          ),
          SizedBox(height: 12.h),
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
          SizedBox(height: 12.h),
          _buildFinalPriceNote(),
        ],
      ),
    );
  }

  /// المغسلة بتعد القطع بعد ما توصلها وممكن تبعت تعديل، والدفع بيتطلب بعدها
  /// فبنوضح من الأول إن الإجمالي ده مبدئي ومفيش دفع دلوقتي
  Widget _buildFinalPriceNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16.r, color: AppColors.primaryColor),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'final_price_note'.tr(),
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
