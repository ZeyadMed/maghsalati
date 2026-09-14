import 'package:flutter/material.dart';
import 'package:maghsalati/core/common_widget/custom_app_bar.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Orders'),
      body: const Center(
        child: Text('This is the Orders Screen'),
      ),
    );
  }
}