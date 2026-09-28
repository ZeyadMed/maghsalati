/// المغسلة اللي راجعة من api/customer/laundries/nearby
/// أي قيمة راجعة null بتتحول لصفر أو نص فاضي عشان الكارت مايقعش
class NearbyLaundryModel {
  final int id;
  final String name;
  final String imageUrl;
  final String address;
  final String cityName;
  final double distanceKm;
  final double averageRating;
  final int reviewsCount;
  final bool isAvailableNow;

  const NearbyLaundryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.cityName,
    required this.distanceKm,
    required this.averageRating,
    required this.reviewsCount,
    required this.isAvailableNow,
  });

  factory NearbyLaundryModel.fromJson(Map<String, dynamic> json) {
    return NearbyLaundryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      isAvailableNow: json['isAvailableNow'] == true,
    );
  }

  /// المدينة والعنوان في سطر واحد، واللي فاضي فيهم مابيتعرضش
  String get fullAddress =>
      [cityName, address].where((part) => part.isNotEmpty).join('، ');
}
