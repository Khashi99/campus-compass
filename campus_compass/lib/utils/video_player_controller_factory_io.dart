import 'dart:io';

import 'package:video_player/video_player.dart';

VideoPlayerController createVideoPlayerController(String path) {
  return VideoPlayerController.file(File(path));
}
