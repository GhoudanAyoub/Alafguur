class ConverterUtility {
  /// Convert a dynamic [value] to integer. If the [value] is `null`, returns
  /// `null`, hence the result is nullable.
  static int? dynamicToNullableInt(dynamic value) {
    if (value == null) {
      return value;
    }

    return value is int ? value : int.parse(value.toString());
  }

  /// Convert a dynamic [value] to integer. If the [value] is `null`, returns 0,
  /// giving a non-nullable result in any case.
  static int dynamicToInt(dynamic value) {
    if (value == null) {
      return 0;
    } else if (value is int) {
      return value;
    }

    final parsedValue = int.tryParse(value.toString());

    return parsedValue ?? 0;
  }

  /// Convert a dynamic [value] to double. If the [value] is `null`, returns
  /// `null`, hence the result is nullable.
  static double? dynamicToNullableDouble(dynamic value) {
    if (value == null) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    }

    return value is double ? value : double.parse(value.toString());
  }

  /// Convert a dynamic [value] to double. If the [value] is `null`, returns
  /// 0.0, giving a non-nullable result in any case.
  static double dynamicToDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    } else if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    }

    final parsedValue = double.tryParse(value.toString());

    return parsedValue ?? 0;
  }

  static List<int>? dynamicListToInt(List? values) {
    if (values == null) {
      return values as List<int>?;
    }

    return values.map((value) => dynamicToInt(value)).toList();
  }

  static List? modelListToJsonList(List? values) {
    if (values == null) {
      return values;
    }

    return values.map((value) => modelToJson(value)).toList();
  }

  static modelToJson(value) {
    if (value == null) {
      return value;
    }

    return value.toJson();
  }

}
