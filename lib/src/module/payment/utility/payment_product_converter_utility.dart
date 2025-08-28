import '../service/model/payment_credit_pack_model.dart';
import '../service/model/payment_membership_plan_model.dart';

class PaymentProductConverterUtility {
  /// Attempt to convert arbitrary JSON to one of the available products.
  /// The result can be an instance of either [PaymentMembershipPlanModel] or
  /// [PaymentCreditPackModel].
  ///
  /// Throws [FormatException] on failure.
  static Object? jsonToProduct(Object? json) {
    if (!(json is Map)) {
      // If the product could not be found, backend will return empty list
      // instead of empty map due to the PHP JSON serialization algorithm.
      // Returning null tells the receiver that the product was not found.
      if (json is List) {
        return null;
      }

      throw ArgumentError(
        'Invalid argument type, Map expected, got ${json.runtimeType}',
      );
    }

    // Convert to Map<String, Object> safely
    Map<String, Object?> safeJson = {};
    try {
      // Convert each key to String and each value to its appropriate type
      (json as Map).forEach((key, value) {
        safeJson[key.toString()] = value;
      });
    } catch (e) {
      throw ArgumentError(
        'Failed to convert Map to Map<String, Object>: ${e.toString()}',
      );
    }

    try {
      return PaymentMembershipPlanModel.fromJson(safeJson);
    } catch (_) {
      try {
        return PaymentCreditPackModel.fromJson(safeJson);
      } catch (__) {
        rethrow;
      }
    }
  }

  /// Changes the given [productId] to conform to the app URL naming scheme
  /// and returns the new value. Opposite of [deurlifyProductId].
  static String urlifyProductId(String productId) {
    return productId.toLowerCase().replaceAll('_', '-');
  }

  /// Changes the given [productId] to conform to the Skadate product naming
  /// scheme and returns the new value. Opposite of [urlifyProductId].
  static String deurlifyProductId(String productId) {
    return productId.toUpperCase().replaceAll('-', '_');
  }

  /// Derives plugin key from the given [productId]. Returns null on failure.
  static String? pluginKeyFromProductId(String productId) {
    if (productId.isEmpty) {
      return null;
    }
    
    // All product ids look like XXX_XXX_<ID>. We're interested only in the
    // XXX_XXX part.
    final regex = RegExp(r'(\w+_\w+)_\d+$', caseSensitive: false, unicode: true);
    final match = regex.firstMatch(productId.toLowerCase());

    if (match == null) {
      // Try alternative pattern without ID
      if (productId.toLowerCase().contains('membership_plan')) {
        return 'membership';
      } else if (productId.toLowerCase().contains('user_credits_pack')) {
        return 'usercredits';
      }
      return null;
    }

    final productType = match.group(1);
    if (productType == null) {
      return null;
    }

    switch (productType) {
      case 'membership_plan':
        return 'membership';

      case 'user_credits_pack':
        return 'usercredits';
    }

    return null;
  }
}
