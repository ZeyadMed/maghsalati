import 'package:flutter/material.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Profile'),
      body: const Center(child: Text('This is the Profile Screen')),
    );
  }
}
