import 'dart:io';

import 'package:equatable/equatable.dart';

class RegisterEvent extends Equatable {
  final String name;
  final String phoneNumber;
  final String address;
  final int cityId;
  final double latitude;
  final double longitude;

  /// صورة البروفايل، null لو المستخدم ماختارش صورة
  final File? image;

  const RegisterEvent({
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.cityId,
    required this.latitude,
    required this.longitude,
    this.image,
  });

  @override
  List<Object?> get props => [
    name,
    phoneNumber,
    address,
    cityId,
    latitude,
    longitude,
    image?.path,
  ];
}
