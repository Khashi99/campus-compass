import 'dart:html' as html;

Future<bool> vibrateWithPattern(List<int> pattern) async {
  if (pattern.isEmpty) {
    return false;
  }

  try {
    final dynamic navigator = html.window.navigator;
    final result = navigator.vibrate(pattern);
    if (result is bool) {
      return result;
    }
    return result != null;
  } catch (_) {
    return false;
  }
}
