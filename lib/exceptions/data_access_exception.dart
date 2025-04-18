// Thrown when a data access operation fails in the DAO layer.
class DataAccessException implements Exception {
  final String message;
  final Object? originalError;

  DataAccessException(this.message, [this.originalError]);

  @override
  String toString() {
    var base = 'DataAccessException: $message';
    if (originalError != null) {
      base += ' – $originalError';
    }
    return base;
  }
}
