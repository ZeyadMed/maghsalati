/// الرقم الصحيح بيتعرض من غير كسور يعني 8 مش 8.0
String formatCartPrice(num value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
