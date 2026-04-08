import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';

/// Generate a thumbnail for a video on web by loading the file into a
/// `VideoElement`, seeking a short time in, drawing to a `CanvasElement`,
/// and returning JPEG bytes.
Future<Uint8List?> generateVideoThumbnail(XFile file) async {
  try {
    final bytes = await file.readAsBytes();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final video = html.VideoElement()
      ..src = url
      ..crossOrigin = 'anonymous'
      ..muted = true
      ..setAttribute('playsinline', 'true');

    final completer = Completer<void>();

    void onLoaded(html.Event e) {
      completer.complete();
    }

    video.addEventListener('loadeddata', onLoaded);

    // Start loading
    video.load();
    await completer.future;

    // seek to 0.1s (some videos need a small offset)
    final seekCompleter = Completer<void>();
    void onSeek(html.Event e) {
      if (!seekCompleter.isCompleted) seekCompleter.complete();
    }
    video.addEventListener('seeked', onSeek);
    try {
      video.currentTime = 0.1;
    } catch (_) {
      // ignore
    }
    // Wait for either seek or short timeout
    await Future.any([
      seekCompleter.future,
      Future.delayed(Duration(milliseconds: 200)),
    ]);

    final videoWidth = video.videoWidth > 0 ? video.videoWidth : 320;
    final videoHeight = video.videoHeight > 0 ? video.videoHeight : 180;

    // scale down to max width 128 while preserving aspect ratio
    final maxWidth = 128;
    final scale = videoWidth > maxWidth ? (maxWidth / videoWidth) : 1.0;
    final canvasWidth = (videoWidth * scale).toInt();
    final canvasHeight = (videoHeight * scale).toInt();

    final canvas = html.CanvasElement(width: canvasWidth, height: canvasHeight);
    final ctx = canvas.context2D;
    ctx.drawImageScaled(video, 0, 0, canvasWidth, canvasHeight);

    final dataUrl = canvas.toDataUrl('image/jpeg', 0.8);
    // dataUrl looks like 'data:image/jpeg;base64,...'
    final comma = dataUrl.indexOf(',');
    final base64Str = dataUrl.substring(comma + 1);
    final bytesOut = base64.decode(base64Str);

    // cleanup
    html.Url.revokeObjectUrl(url);
    video.remove();
    canvas.remove();

    return Uint8List.fromList(bytesOut);
  } catch (e) {
    return null;
  }
}
