import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/widget/flexiable_image.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';

/// كارت الصور والملاحظات: الصور جنب بعض والدوس على أي واحدة بيفتحها كبيرة،
/// وتحتها الملاحظات. الشاشة بتعرضه بس لو فيه حاجة منهم ([OrderModel.hasNotesOrImages])
class OrderNotesCard extends StatelessWidget {
  final OrderModel order;

  const OrderNotesCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return OrderSectionCard(
      title: 'order_photos_notes'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (order.images.isNotEmpty) _buildImages(context),
          if (order.images.isNotEmpty && order.notes.isNotEmpty) Gap(12.h),
          if (order.notes.isNotEmpty) _buildNotes(),
        ],
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    final size = 76.r;
    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: order.images.length,
        separatorBuilder: (_, _) => Gap(8.w),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _OrderImageViewer.show(context, order.images, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: FlexibleImage(
              source: order.images[index],
              width: size,
              height: size,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 20.r,
            color: AppColors.greyColor2,
          ),
          Gap(8.w),
          Expanded(
            child: Text(
              order.notes,
              style: TextStyles.greyColor2Regular14.copyWith(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}

/// الصور بالحجم الكامل على خلفية سودا، بتتقلب بالسحب وتتكبر بالصوابع
class _OrderImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _OrderImageViewer({required this.images, required this.initialIndex});

  static Future<void> show(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: AppColors.blackColor,
      useSafeArea: false,
      builder: (_) =>
          _OrderImageViewer(images: images, initialIndex: initialIndex),
    );
  }

  @override
  State<_OrderImageViewer> createState() => _OrderImageViewerState();
}

class _OrderImageViewerState extends State<_OrderImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          itemBuilder: (context, index) => InteractiveViewer(
            maxScale: 4,
            child: Center(
              child: FlexibleImage(
                source: widget.images[index],
                width: double.infinity,
                borderRadius: 0,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 8.h,
          end: 8.w,
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: AppColors.whiteColor),
          ),
        ),
      ],
    );
  }
}
