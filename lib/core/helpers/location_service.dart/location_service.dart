// // import 'package:geolocator/geolocator.dart';

// // class LocationService {
// //   // التأكد من تفعيل اللوكيشن والصلاحيات
// //   Future<bool> _handlePermission() async {
// //     bool serviceEnabled;
// //     LocationPermission permission;

// //     // هل الخدمة مفعلة؟
// //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       return false;
// //     }

// //     // حالة الصلاحيات
// //     permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         return false;
// //       }
// //     }

// //     if (permission == LocationPermission.deniedForever) {
// //       return false;
// //     }

// //     return true;
// //   }

// //   // جلب اللوكيشن الحالي
// //   Future<Position?> getCurrentLocation() async {
// //     final hasPermission = await _handlePermission();
// //     if (!hasPermission) return null;

// //     return await Geolocator.getCurrentPosition(
// //       desiredAccuracy: LocationAccuracy.high,
// //     );
// //   }
// // }

// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// Future<String?> getCurrentAddress() async {
//   try {
//     // التحقق من الصلاحيات والخدمة
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await Geolocator.openLocationSettings();
//       if (!serviceEnabled) return null;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return null;
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return null;
//     }

//     // الحصول على الإحداثيات
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     // تحويل الإحداثيات إلى عنوان
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );

//     if (placemarks.isNotEmpty) {
//       final place = placemarks.first;
//       return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
//     } else {
//       return "تعذر تحديد العنوان";
//     }
//   } catch (e) {
//     print("Error: $e");
//     return null;
//   }
// }

