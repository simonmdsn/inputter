import 'package:inputter/inputter.dart';
import 'package:win32/win32.dart' as win32;

void main() {
  var windowManager = WindowManager();
  String searchTitle = "discord";
  var windowByBestTitleMatch =
      windowManager.getWindowByBestTitleMatch(searchTitle);
  if (windowByBestTitleMatch != null) {
    print(
        '${windowByBestTitleMatch.title} was the best match found for search title $searchTitle');

    var i = 0;
    while (i < 200) {
      windowManager.moveWindowXY(windowByBestTitleMatch as WindowsWindow, i, 20);
      i += 1;
      win32.Sleep(1);
    }


    windowManager.resizeWindow(
        windowByBestTitleMatch as WindowsWindow, Rectangle.fromSize(1000, 1000));
  }
}
