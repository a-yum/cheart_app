class ImageHandlerException implements Exception {
  final String message;
  ImageHandlerException(this.message);

  @override
  String toString() => 'ImageHandlerException: $message';
}
