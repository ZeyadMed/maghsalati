/// الإعلان اللي راجع من api/auth/advertisements
/// الهوم بيعرض الصورة بس، فمابناخدش العنوان ولا targetType
class AdvertisementModel {
  final int id;
  final String imageUrl;

  const AdvertisementModel({required this.id, required this.imageUrl});

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString().trim() ?? '',
    );
  }
}
