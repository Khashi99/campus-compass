import 'dart:html' as html;

Future<bool> playBrowserAlertTone(int count) async {
  if (count <= 0) {
    return false;
  }

  try {
    final safeCount = count < 1 ? 1 : (count > 3 ? 3 : count);
    final sourceUrl = Uri.base.resolve('sounds/alert.wav').toString();

    for (var i = 0; i < safeCount; i++) {
      final tone = html.AudioElement(sourceUrl)
        ..preload = 'auto'
        ..volume = 0.9;

      await tone.play();
      if (i < safeCount - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    }

    return true;
  } catch (_) {
    return false;
  }
}