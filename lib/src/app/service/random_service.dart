import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Random values generator.
class RandomService {
  /// Generates a cryptographically secure random nonce
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a random integer between [min] and [max].
  int integer({int min = 0, int max = 1000000}) {
    if (min > max) {
      max = min + 1;
    }

    return (Random().nextDouble() * (max - min) + min).floor();
  }

  /// Generate a random string with optional [prefix]. Generated strings are
  /// URL-friendly.
  String string({String? prefix, int minLength = 3, int maxLength = 16}) {
    var buffer = StringBuffer();

    if (prefix != null) {
      buffer.write(prefix);
    }

    final min = (pow(10, minLength) - 1).toInt();
    final max = (pow(10, maxLength) - 1).toInt();

    buffer.write(
      integer(min: min, max: max).toRadixString(32),
    );

    return buffer.toString();
  }
}
