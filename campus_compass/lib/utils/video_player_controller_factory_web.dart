import 'package:video_player/video_player.dart';

VideoPlayerController createVideoPlayerController(String path) {
  return VideoPlayerController.networkUrl(Uri.parse(path));
}
