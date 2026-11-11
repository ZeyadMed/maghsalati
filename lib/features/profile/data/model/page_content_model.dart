import 'package:maghsalati/core/http/endpoints.dart';

/// الصفحات اللي محتواها بيتكتب من لوحة التحكم، وكلها اند بوينتس مفتوحة
/// بترجع نفس الشكل { content, updatedAt } فبتتعرض بنفس الشاشة
/// ما عدا [scopeOfService] اللي ليها شاشة بخريطة فوق النص (ServiceAreaScreen)
enum ContentPage {
  privacyPolicy(Endpoints.privacyPolicy, 'privacy_policy'),
  scopeOfService(Endpoints.scopeOfService, 'service_area'),
  serviceProvider(Endpoints.serviceProvider, 'service_provider');

  final String endpoint;

  /// مفتاح الترجمة بتاع عنوان الشاشة
  final String titleKey;

  const ContentPage(this.endpoint, this.titleKey);
}

/// محتوى صفحة من [ContentPage]
/// الـ content بيبقى HTML متكتب من لوحة التحكم
class PageContentModel {
  final String content;

  /// null لو السيرفر مابعتش تاريخ أو بعته بشكل غلط
  final DateTime? updatedAt;

  const PageContentModel({required this.content, required this.updatedAt});

  factory PageContentModel.fromJson(Map<String, dynamic> json) {
    return PageContentModel(
      content: json['content']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
