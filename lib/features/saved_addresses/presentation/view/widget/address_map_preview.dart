import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:maghsalati/core/style/app_colors.dart';

/// خريطة صغيرة ثابتة عليها دبوس العنوان، عشان اليوزر يتأكد من المكان
/// من غير ما يفتح شاشة الخريطة. الدوس عليها بيتعمل من بره
class AddressMapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double? height;

  const AddressMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return SizedBox(
      height: height ?? 140.h,
      // IgnorePointer عشان الدوسة توصل للي برا (فتح شاشة الخريطة)
      child: IgnorePointer(
        child: FlutterMap(
          // initialCenter مابيتغيرش بعد أول بناء، فالـ key بيبني الخريطة
          // من جديد لما الموقع يتغير
          key: ValueKey('$latitude,$longitude'),
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.theone.maghsalati',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40.r,
                  height: 40.r,
                  // سن الدبوس على النقطة بالظبط مش نصه
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.location_on,
                    size: 40.r,
                    color: AppColors.redColor2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
