import 'package:inputter/inputter.dart';
import 'package:win32/win32.dart' as win32;
import 'package:ffi/ffi.dart';
import 'dart:ffi';

/// while program is running, remaps virtual key 'E' to 'H'
/// FIXME
/// must make use of win32 GetMessage, otherwise the mapping won't work.
/// https://github.com/timsneath/win32/issues/509
void main() {
  var keyboardManager = KeyboardManager();
  keyboardManager.remapKey(VirtualKey.E, VirtualKey.H);
  final msg = calloc<win32.MSG>();
  while (win32.GetMessage(msg, win32.NULL, 0, 0) != 0) {
    win32.TranslateMessage(msg);
  }
}
