import 'package:inputter/inputter.dart';

void main() {
  final cursorManager = CursorManager();
  var pixel1 = cursorManager.getPixel(5, 5);
  var pixel2 = cursorManager.getPixelAtCursor();
  print("pixel1 color: ${pixel1.color}");
  print("pixel2 color: ${pixel2.color}");
  print("are pixel colors equal: ${pixel1.color == pixel2.color}");
}
