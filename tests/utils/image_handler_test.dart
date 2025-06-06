import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/utils/image_handler.dart';
import 'package:cheart/exceptions/image_handler_exception.dart';

void main() {
  group('ImageHandler.deleteImage', () {
    test('deletes an existing file successfully', () async {
      // Create a temporary file
      final tempDir = Directory.systemTemp.createTempSync();
      final filePath = '${tempDir.path}/test_image.jpg';
      final file = File(filePath);
      await file.writeAsString('dummy content');
      expect(await file.exists(), isTrue);

      // Delete via ImageHandler
      await ImageHandler.deleteImage(filePath);

      // The file should no longer exist
      expect(await file.exists(), isFalse);

      // Cleanup temp directory
      await tempDir.delete(recursive: true);
    });

    test('throws ImageHandlerException when deletion fails', () async {
      // Use a path that is almost certainly invalid or protected
      final badPath = '/this/path/does/not/exist/image.jpg';
      // Ensure the file truly doesn't exist
      final file = File(badPath);
      if (await file.exists()) {
        await file.delete();
      }

      // Attempt deletion and expect our custom exception
      expect(
        () => ImageHandler.deleteImage(badPath),
        throwsA(isA<ImageHandlerException>()),
      );
    });
  });
}
