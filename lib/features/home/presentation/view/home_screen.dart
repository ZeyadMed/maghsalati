import 'package:flutter/material.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home'),
      body: const Center(
        child: Text('Welcome to the Home Screen'),
      ),
    );
  }
}