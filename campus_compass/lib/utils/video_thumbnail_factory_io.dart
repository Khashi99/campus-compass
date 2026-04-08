import 'dart:typed_data';

import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';

/// Generate a thumbnail for a video on native platforms using the
/// `video_thumbnail` package. Returns `Uint8List?` or null on failure.
Future<Uint8List?> generateVideoThumbnail(XFile file) async {
  try {
    return await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 70,
    );
  } catch (_) {
    return null;
  }
}
