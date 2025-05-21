import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:cheart/exceptions/image_handler_exception.dart';


class ImageHandler {
  ImageHandler._();

  static final ImagePicker _picker = ImagePicker();
  static final Uuid _uuid = Uuid();

  // Launches image picker, enforces circle crop with zoom,
  // compresses and saves the final image to profile_images directory.
  //
  // Returns the saved image path, or null if user cancels.
  // Throws ImageHandlerException on internal errors.
  static Future<String?> pickAndCropImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // 1. Pick an image
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked == null) return null;

      // 2. Crop in circle (square aspect lock) with zoom enabled
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            hideBottomControls: true,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            cropStyle: CropStyle.circle,
          ),
        ],
      );
      if (cropped == null) return null;

      // 3. Prepare save directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/profile_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 4. Copy cropped file to app folder with unique name
      final fileName = '${_uuid.v4()}.jpg';
      final saved = await File(cropped.path)
          .copy('${imagesDir.path}/$fileName');

      return saved.path;
    } catch (e, st) {
      debugPrint('ImageHandler error picking/cropping image: $e\n$st');
      throw ImageHandlerException('Failed to pick & crop image: $e');
    }
  }

  // Deletes the image file at [path] if it exists.
  static Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, st) {
      debugPrint('ImageHandler error deleting image: $e\n$st');
      throw ImageHandlerException('Failed to delete image at $path: $e');
    }
  }
}
