/// قراية مرنة للـ JSON لأن الـ Swagger مش موضح شكل الريسبونس بتاع تفاصيل الطلب
/// (الرحلات والتعديل والدفع)، فبندور على أكتر من اسم للحقل الواحد لحد ما الشكل
/// الحقيقي يتثبت. نفس الفكرة اللي في أبلكيشن المندوب
extension JsonReader on Map<String, dynamic> {
  /// أول قيمة مش null من المفاتيح دي، في الروت أو جوه الـ maps اللي في [inside]
  dynamic pick(List<String> keys, {List<String> inside = const []}) {
    for (final key in keys) {
      final value = this[key];
      if (value != null) return value;
    }
    for (final parent in inside) {
      final nested = this[parent];
      if (nested is Map<String, dynamic>) {
        final value = nested.pick(keys);
        if (value != null) return value;
      }
    }
    return null;
  }

  Map<String, dynamic>? pickMap(List<String> keys) {
    final value = pick(keys);
    return value is Map<String, dynamic> ? value : null;
  }

  /// الليستة بس لو عناصرها maps، وأي عنصر تاني بيتشال
  List<Map<String, dynamic>> pickList(List<String> keys) {
    final value = pick(keys);
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  String pickString(List<String> keys, {List<String> inside = const []}) =>
      pick(keys, inside: inside)?.toString() ?? '';

  int? pickInt(List<String> keys, {List<String> inside = const []}) =>
      asInt(pick(keys, inside: inside));

  num? pickNum(List<String> keys, {List<String> inside = const []}) =>
      asNum(pick(keys, inside: inside));
}

int? asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

num? asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
