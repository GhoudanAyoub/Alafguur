abstract class ApplicationException implements Exception {
  final String? message;
  final Exception? previous;

  ApplicationException(
    this.message, {
    this.previous,
  });
}
