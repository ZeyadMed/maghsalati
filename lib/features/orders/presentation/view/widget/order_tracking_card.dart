import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';
import 'package:maghsalati/core/style/app_colors.dart';
import 'package:maghsalati/features/orders/data/model/order_model.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_driver_tile.dart';
import 'package:maghsalati/features/orders/presentation/view/widget/order_section_card.dart';

/// كارت المناديب: خريطة عليها بيت العميل والمغسلة والمندوب اللي شغال دلوقتي
/// (اللي السيرفر بعت مكانه منهم)، وتحتها كارت لكل رحلة لوحده: مندوب الاستلام
/// الأول وبعده مندوب التسليم، وكل واحد بحالته.
/// الخريطة بتبان بس والطلب لسه شغال وفيه نقطة واحدة على الأقل
class OrderTrackingCard extends StatelessWidget {
  final OrderModel order;

  /// [OrderModel.driverTrips]، والكارت مابيتعرضش لو فاضية
  final List<OrderTripModel> trips;

  /// بيفتح شاشة تقييم مندوب الرحلة
  final ValueChanged<OrderTripModel> onRateDriver;

  /// العميل قيّم مندوب الرحلة دي (من السيرفر أو من الشاشة)
  final bool Function(OrderTripModel trip) isDriverRated;

  const OrderTrackingCard({
    super.key,
    required this.order,
    required this.trips,
    required this.onRateDriver,
    required this.isDriverRated,
  });

  @override
  Widget build(BuildContext context) {
    final markers = _markers();

    return OrderSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (order.isCurrent && markers.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: _buildMap(markers),
            ),
            Gap(12.h),
          ],
          for (var i = 0; i < trips.length; i++) ...[
            if (i > 0) Gap(10.h),
            _buildTile(trips[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildTile(OrderTripModel trip) {
    final isRated = isDriverRated(trip);
    return OrderDriverTile(
      trip: trip,
      stage: order.tripStage(trip),
      onRate: !isRated && order.canRateDriver(trip)
          ? () => onRateDriver(trip)
          : null,
      isRated: isRated,
    );
  }

  List<_MapPoint> _markers() => [
    if (order.hasLocation)
      _MapPoint(
        LatLng(order.latitude!, order.longitude!),
        Icons.home_rounded,
        AppColors.primaryColor,
      ),
    if (order.hasLaundryLocation)
      _MapPoint(
        LatLng(order.laundryLatitude!, order.laundryLongitude!),
        Icons.storefront_rounded,
        AppColors.orangeColor,
      ),
    // المندوب اللي لسه شغال بس، مش اللي خلص رحلته
    for (final trip in trips)
      if (trip.hasDriverLocation && order.tripStage(trip).isActive)
        _MapPoint(
          LatLng(trip.driverLatitude!, trip.driverLongitude!),
          Icons.delivery_dining_rounded,
          AppColors.greenColor,
        ),
  ];

  /// نقطة واحدة بتبقى في النص، وأكتر من واحدة الخريطة بتتظبط عليهم كلهم.
  /// ثابتة عشان السحب جوه الشاشة مايتلخبطش مع تحريك الخريطة
  Widget _buildMap(List<_MapPoint> markers) {
    final points = markers.map((marker) => marker.point).toList();

    return SizedBox(
      height: 170.h,
      child: IgnorePointer(
        child: FlutterMap(
          // initialCenter مابيتغيرش بعد أول بناء، فالـ key بيبنيها من جديد
          // لما المندوب يتحرك أو النقط تتغير
          key: ValueKey(points.join('|')),
          options: MapOptions(
            initialCenter: points.first,
            initialZoom: 15,
            initialCameraFit: points.length > 1
                ? CameraFit.coordinates(
                    coordinates: points,
                    padding: EdgeInsets.all(40.r),
                    maxZoom: 16,
                  )
                : null,
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
                for (final marker in markers)
                  Marker(
                    point: marker.point,
                    width: 36.r,
                    height: 36.r,
                    child: _buildMarker(marker),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker(_MapPoint marker) {
    return Container(
      decoration: BoxDecoration(
        color: marker.color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.whiteColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(marker.icon, size: 18.r, color: AppColors.whiteColor),
    );
  }
}

class _MapPoint {
  final LatLng point;
  final IconData icon;
  final Color color;

  const _MapPoint(this.point, this.icon, this.color);
}
