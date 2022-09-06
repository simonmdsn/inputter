import 'dart:ffi';
import 'dart:io';

import 'package:inputter/src/image_util.dart';
import 'package:win32/win32.dart' as win32;

void main() {
  var captureImage = ImageUtil.captureImage();
  if (captureImage != null) {
    var file = File("screenshot.bmp")..writeAsBytesSync(captureImage.getBytes());
    file.path;
    win32.ShellExecute(0, win32.TEXT('open'), win32.TEXT('mspaint.exe'),
        win32.TEXT(file.absolute.path), nullptr, win32.SW_SHOW);
    win32.Sleep(500);
    file.delete();
  }
}
