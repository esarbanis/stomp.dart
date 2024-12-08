class StompException implements Exception {
  final String message;

  StompException(this.message);

  @override
  String toString() {
    return 'StompException: $message';
  }
}
