import 'dart:ffi';

import 'package:inputter/inputter.dart';
import 'package:win32/win32.dart' as win32;


void main() {
  win32.ShellExecute(0, win32.TEXT('open'), win32.TEXT('notepad.exe'), nullptr, nullptr, win32.SW_SHOW);
  
  win32.Sleep(500);
  
  var wm = WindowManager();
  
  var windowByTitle = wm.getWindowByTitle("Notepad");
  wm.putWindowToFront(windowByTitle as WindowsWindow);
  win32.Sleep(500);

  wm.resizeWindow(windowByTitle, Rectangle.fromSize(500, 500));
  win32.Sleep(500);
  wm.moveWindowXY(windowByTitle, 50, 50);

  var keyboardManager = KeyboardManager();
  "Hello, from Notepad!".split("").forEach((element) {
    keyboardManager.sendInputString(element);
    win32.Sleep(100);
  });
  var mouseManager = CursorManager();
  mouseManager.setCursorPositionXY(50, 60);
  var i = 5;
  while(i < 470) {
    mouseManager.pushCursorX(5);
    i+=5;
    win32.Sleep(1);
  }
  mouseManager.sendInputs([MouseInput.leftDown,MouseInput.leftUp]);
  win32.Sleep(500);
  keyboardManager.sendKey(VirtualKey.VK_RIGHT);
  win32.Sleep(500);
  keyboardManager.sendKey(VirtualKey.VK_RETURN);
}