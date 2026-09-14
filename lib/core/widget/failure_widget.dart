import 'package:flutter/material.dart';
import 'package:maghsalati/core/extensions/context_extension.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/core/style/assets.dart';
import 'package:maghsalati/core/theme/text_styles.dart';
import 'package:maghsalati/core/common_widget/label.dart';

class FailureWidget<T> extends StatelessWidget {
  final RefreshCallback? onRefresh;
  final String errorMessage;

  const FailureWidget({super.key, this.onRefresh, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return onRefresh == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.assetsImagesFaliureWidget,
                  width: 75,
                  height: 75,
                ),
                const SizedBox(height: 16),
                LocalizedLabel(
                  text: errorMessage,
                  style: TextStyles.darkBold16,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   Assets.assetsImagesEmpty, // Replace with your image path
                    //   width: 150,
                    //   height: 150,
                    // ),
                    const SizedBox(height: 16),
                    // Add spacing between image and text
                    Label(text: errorMessage, textAlign: TextAlign.center),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  displacement: 50,
                  edgeOffset: 50,
                  strokeWidth: 3,
                  onRefresh: onRefresh!,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(height: context.screenHeight),
                  ),
                ),
              ),
            ],
          );
  }
}
