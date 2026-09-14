import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/theme/text_styles.dart';

class DefaultExpansionTile extends StatefulWidget {
  final String name;
  final String image;
  final List? options;
  final List<Widget>? optionsWidget;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double radius;
  final bool initiallyExpanded;

  const DefaultExpansionTile({
    super.key,
    required this.name,
    this.image = '',
    this.options,
    this.onTap,
    this.optionsWidget,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.radius = 0,
    this.initiallyExpanded = false,
  });

  @override
  State<DefaultExpansionTile> createState() => _DefaultExpansionTileState();
}

class _DefaultExpansionTileState extends State<DefaultExpansionTile> {
  bool isOpen = false;
  int? isSelected;
  String lastChoice = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        // Header should always use primary color background, so text stays white
        collapsedTextColor: Colors.white,
        textColor: Colors.white,
        initiallyExpanded: widget.initiallyExpanded,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          side: !isOpen
              ? const BorderSide(color: Colors.grey, width: 0.5)
              : BorderSide.none,
        ),
        // Keep header color as primary whether expanded or not
        backgroundColor: widget.backgroundColor ?? AppColors.primaryColor,
        collapsedBackgroundColor:
            widget.backgroundColor ?? AppColors.primaryColor,
        // Icons on header should be white to contrast the primary background
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        onExpansionChanged: (value) {
          setState(() {
            isOpen = value;
          });
        },
        leading: widget.image.isEmpty ? null : _leading(),
        title: _title(),
        // Wrap the expanded body in a white container so children appear on white
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(widget.radius),
                bottomRight: Radius.circular(widget.radius),
              ),
            ),
            child: Column(children: widget.optionsWidget ?? options(context)),
          ),
        ],
      ),
    );
  }

  Widget _leading() {
    return Image.network(
      widget.image,
      width: 30.w,
      height: 30.h,
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: 30.w, height: 30.w),
    );
  }

  Widget _title() {
    return Text(
      widget.name,
      style: TextStyles.blackBold12.copyWith(
        fontSize: 15.sp,
        color: isOpen ? Colors.white : widget.textColor ?? AppColors.blackColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  options(BuildContext context) =>
      List.generate((widget.options ?? []).length, (index) {
        return InkWell(
          onTap: () {
            widget.onTap?.call(index);
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              border: Border.all(color: AppColors.greyColor.withOpacity(.5)),
            ),
            child: Text(
              (widget.options ?? [])[index],
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      });
}
