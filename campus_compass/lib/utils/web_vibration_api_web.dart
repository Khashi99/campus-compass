import 'dart:html' as html;

Future<bool> vibrateWithPattern(List<int> pattern) async {
  if (pattern.isEmpty) {
    return false;
  }

  try {
    final dynamic navigator = html.window.navigator;
    final result = navigator.vibrate(pattern);
    if (result is bool) {
      if (result) {
        return true;
      }
    } else if (result != null) {
      return true;
    }
  } catch (_) {
    // Ignore and attempt iOS Safari fallback below.
  }

  if (_isIOSSafari()) {
    return _attemptSafariSwitchHaptic(_pulseCountFromPattern(pattern));
  }

  return false;
}

bool _isIOSSafari() {
  final agent = html.window.navigator.userAgent.toLowerCase();
  final isIOS =
      agent.contains('iphone') ||
      agent.contains('ipad') ||
      agent.contains('ipod');
  final isSafari =
      agent.contains('safari') &&
      !agent.contains('crios') &&
      !agent.contains('fxios') &&
      !agent.contains('edgios');
  return isIOS && isSafari;
}

int _pulseCountFromPattern(List<int> pattern) {
  var pulses = 0;
  for (var i = 0; i < pattern.length; i += 2) {
    if (pattern[i] > 0) {
      pulses += 1;
    }
  }
  return pulses <= 1 ? 1 : 2;
}

Future<bool> _attemptSafariSwitchHaptic(int pulseCount) async {
  final body = html.document.body;
  if (body == null) {
    return false;
  }

  final toggle = html.InputElement()
    ..type = 'checkbox'
    ..setAttribute('role', 'switch')
    ..tabIndex = -1
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '0'
    ..style.opacity = '0'
    ..style.pointerEvents = 'none';

  body.append(toggle);

  try {
    for (var i = 0; i < pulseCount; i++) {
      toggle.checked = !(toggle.checked ?? false);
      toggle.dispatchEvent(html.Event('input', canBubble: true));
      toggle.dispatchEvent(html.Event('change', canBubble: true));
      if (i < pulseCount - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }
    }
    return true;
  } catch (_) {
    return false;
  } finally {
    toggle.remove();
  }
}
