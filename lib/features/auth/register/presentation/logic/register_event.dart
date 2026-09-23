import 'package:equatable/equatable.dart';

class RegisterEvent extends Equatable{
final String name;
    final String phoneNumber;
    final String password;
    final  String address;
    final  int cityId;
    final  double latitude;
    final double longitude;
    final String deviceInfo;
    final String deviceId;

  const RegisterEvent({
    required this.name,
    required this.phoneNumber,
    required this.password,
    required this.address,
    required this.cityId,
    required this.latitude,
    required this.longitude,
    required this.deviceInfo,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [
    name,
    phoneNumber,
    password,
    address,
    cityId,
    latitude,
    longitude,
    deviceInfo,
    deviceId,
  ];
}