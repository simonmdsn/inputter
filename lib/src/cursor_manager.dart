import 'package:inputter/inputter.dart';
import 'package:inputter/src/window_manager.dart';
import 'package:win32/win32.dart' as win32;
import 'package:ffi/ffi.dart';
import 'dart:ffi';

class CursorManager {
  Point getCursorPosition() {
    var pointer = calloc<win32.POINT>();
    win32.GetCursorPos(pointer);
    var ref = pointer.ref;
    win32.free(pointer);
    return Point(ref.x, ref.y);
  }

  void setCursorPositionXY(int x, int y) {
    win32.SetCursorPos(x, y);
  }

  void setCursorPosition(Point point) {
    setCursorPositionXY(point.x, point.y);
  }

  void pushCursorXY(int x, int y) {
    var cursorPosition = getCursorPosition();
    setCursorPositionXY(cursorPosition.x + x, cursorPosition.y + y);
  }

  void pushCursorX(int x) {
    pushCursorXY(x, 0);
  }

  void pushCursorY(int y) {
    pushCursorXY(0, y);
  }

  void pushCursor(Point point) {
    pushCursorXY(point.x, point.y);
  }

  /// Should be used with caution.
  /// I.e. can lock your windows if you do not release [MouseInput.leftDown] with [MouseInput.leftUp]
  void sendInputs(List<MouseInput> inputs) {
    final mouse = calloc<win32.INPUT>();
    mouse.ref.type = win32.INPUT_MOUSE;
    for (MouseInput input in inputs) {
      mouse.ref.mi.dwFlags = input.input;
      win32.MOUSEEVENTF_RIGHTUP;
      win32.SendInput(1, mouse, sizeOf<win32.INPUT>());
    }
    win32.free(mouse);
  }

  Pixel getPixelAtCursor() {
    var cursorPosition = getCursorPosition();
    return getPixel(cursorPosition.x, cursorPosition.y);
  }

  Pixel getPixel(int x, int y) {
    var DC = win32.GetDC(win32.NULL);
    var pixel = win32.GetPixel(DC, x, y);
    return Pixel(x, y, RGB.fromColorref(pixel));
  }
}

/// from [constants_nodoc.dart]
enum MouseInput {
  leftDown(0x0002),
  leftUp(0x0004),
  rightDown(0x0008),
  rightUp(0x0010),
  middleDown(0x0020),
  middleUp(0x0040),
  xDown(0x0080),
  xUp(0x0100),
  wheel(0x0800),
  hWheel(0x01000);

  final int input;

  const MouseInput(this.input);
}

extension BitInt on int {
  /// returns integer representation of byte at nth position.
  /// i.e:
  /// n = 0 is first byte
  /// n = 1 is second byte
  /// [int] in dart is a 64-bit integer, so beyond n = 7 is just gonna yield 0.
  int getByteAtPosition(int n) => (this >> (8 * n)) & 0xff;
}

class Pixel {
  final int x, y;
  final RGB color;

  Pixel(this.x, this.y, this.color);
}

class RGB {
  /// is a uint32 representation of RGB
  /// The low-order byte contains a value for the relative intensity of red;
  /// the second byte contains a value for green;
  /// and the third byte contains a value for blue.
  /// The high-order byte must be zero. The maximum value for a single byte is 0xFF.
  /// as per https://docs.microsoft.com/en-us/windows/win32/gdi/colorref
  /// can use [color.toHexString(32)] to get a string representation
  /// examples:
  /// rgbRed   =  0x000000FF;
  /// rgbGreen =  0x0000FF00;
  /// rgbBlue  =  0x00FF0000;
  /// rgbBlack =  0x00000000;
  /// rgbWhite =  0x00FFFFFF;
  final int colorref;
  final int red;
  final int green;
  final int blue;

  RGB(this.colorref, this.red, this.green, this.blue);

  factory RGB.fromColorref(int colorref) {
    return RGB(colorref, colorref.getByteAtPosition(0),
        colorref.getByteAtPosition(1), colorref.getByteAtPosition(2));
  }

  @override
  bool operator ==(Object other) {
    return other is RGB &&
        red == other.red &&
        blue == other.blue &&
        green == other.green;
  }

  @override
  int get hashCode => red.hashCode ^ blue.hashCode ^ green.hashCode;

  @override
  String toString() {
    return "red: $red, green $green, blue: $blue";
  }
}
