import 'dart:ffi';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:inputter/src/string_util.dart';
import 'package:win32/win32.dart' as win32;

class Rectangle {
  final Point topLeft, bottomRight;

  Rectangle(this.topLeft, this.bottomRight);

  factory Rectangle.fromCoordinates(
      int topX, int topY, int bottomX, int bottomY) {
    return Rectangle(Point(topX, topY), Point(bottomX, bottomY));
  }

  factory Rectangle.fromSize(int width, int height) {
    return Rectangle(Point(0, 0), Point(width, height));
  }

  get width => bottomRight.x - topLeft.x;

  get height => bottomRight.y - topLeft.y;

  @override
  String toString() =>
      "Rectangle={ topLeft: $topLeft, bottomRight: $bottomRight }";
}

class Point {
  final int x, y;

  Point(this.x, this.y);

  @override
  String toString() => "Point={ x: $x, y: $y }";
}

class Window {
  final String title;
  final Rectangle rect;

  Window(this.title, this.rect);
}

class WindowsWindow extends Window {
  final int hwnd;
  final win32.WINDOWINFO windowsInfo;

  WindowsWindow(this.hwnd, this.windowsInfo, super.title, super.rect);
}

abstract class IWindowManager {
  List<Window> getWindows();
}

class WindowManager implements IWindowManager {
  static final List<WindowsWindow> _windows = [];

  @override
  List<Window> getWindows() {
    enumerateWindows();
    for (var value in _windows) {
      print(value.title);
    }
    return _windows;
  }

  static void enumerateWindows() {
    _windows.clear();
    final wndProc = Pointer.fromFunction<win32.EnumWindowsProc>(_getWindows, 0);
    win32.EnumWindows(wndProc, 0);
  }

  static int _getWindows(int hWnd, int ptr) {
    // Don't enumerate windows unless they are marked as WS_VISIBLE
    if (win32.IsWindowVisible(hWnd) == win32.FALSE) return win32.TRUE;
    var pwi = calloc<win32.WINDOWINFO>();
    win32.GetWindowInfo(hWnd, pwi);
    var rcWindow = pwi.ref.rcWindow;
    final length = win32.GetWindowTextLength(hWnd);
    if (length == 0) {
      return win32.TRUE;
    }
    final buffer = win32.wsalloc(length + 1);
    win32.GetWindowText(hWnd, buffer, length + 1);
    _windows.add(WindowsWindow(
        hWnd,
        pwi.ref,
        buffer.toDartString(length: length),
        Rectangle.fromCoordinates(
            rcWindow.left, rcWindow.top, rcWindow.right, rcWindow.bottom)));
    win32.free(buffer);
    win32.free(pwi);
    return win32.TRUE;
  }

  Window? getWindowByTitle(String title) {
    enumerateWindows();
    return _windows.firstWhere(
        (element) => element.title.toLowerCase().contains(title.toLowerCase()));
  }

  Window? getWindowByBestTitleMatch(String title) {
    enumerateWindows();
    var map = {for (var e in _windows) e.title.fuzzyScore(title): e};
    var highestScore = map.keys.reduce(max);
    return map.containsKey(highestScore) ? map[highestScore] : null;
  }

  void putWindowToFront(WindowsWindow window) {
    win32.SetForegroundWindow(window.hwnd);
  }

  void resizeWindow(WindowsWindow window, Rectangle rectangle) {
    win32.SetWindowPos(
        window.hwnd, 0, 0, 0, rectangle.width, rectangle.height, 0x0002);
  }

  void moveWindow(WindowsWindow window, Point point) {
    win32.SetWindowPos(window.hwnd, 0, point.x, point.y, 0, 0, 0x0001);
  }

  void moveWindowXY(WindowsWindow window, int x, int y) {
    win32.SetWindowPos(window.hwnd, 0, x, y, 0, 0, 0x0001);
  }
}
