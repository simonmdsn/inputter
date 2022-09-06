import 'dart:io';

import 'package:image/image.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';

class ImageUtil {
  /// check https://stackoverflow.com/a/3586280/1893164
  static Image? captureImage() {
    final hdcScreen = GetDC(GetDesktopWindow());
    final hdcMemDC = CreateCompatibleDC(hdcScreen);
    final bmpScreen = calloc<BITMAP>();
    Image? image;

    try {
      if (hdcMemDC == 0) {
        return null;
      }

      final rcClient = calloc<RECT>();
      GetClientRect(GetDesktopWindow(), rcClient);

      final hbmScreen = CreateCompatibleBitmap(
          hdcScreen,
          rcClient.ref.right - rcClient.ref.left,
          rcClient.ref.bottom - rcClient.ref.top);

      SelectObject(hdcMemDC, hbmScreen);

      BitBlt(hdcMemDC, 0, 0, rcClient.ref.right - rcClient.ref.left,
          rcClient.ref.bottom - rcClient.ref.top, hdcScreen, 0, 0, SRCCOPY);

      GetObject(hbmScreen, sizeOf<BITMAP>(), bmpScreen);

      final bitmapFileHeader = calloc<BITMAPFILEHEADER>();
      final bitmapInfoHeader = calloc<BITMAPINFOHEADER>()
        ..ref.biSize = sizeOf<BITMAPINFOHEADER>()
        ..ref.biWidth = bmpScreen.ref.bmWidth
        ..ref.biHeight = bmpScreen.ref.bmHeight
        ..ref.biPlanes = 1
        ..ref.biBitCount = 32
        ..ref.biCompression = BI_RGB;

      final dwBmpSize =
          ((bmpScreen.ref.bmWidth * bitmapInfoHeader.ref.biBitCount + 31) /
                  32 *
                  4 *
                  bmpScreen.ref.bmHeight)
              .toInt();

      final lpBitmap = calloc<Uint8>(dwBmpSize);

      GetDIBits(hdcScreen, hbmScreen, 0, bmpScreen.ref.bmHeight, lpBitmap,
          bitmapInfoHeader.cast(), DIB_RGB_COLORS);

      final hFile = CreateFile(TEXT('screen.bmp'), GENERIC_WRITE, 0, nullptr,
          CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

      final dwSizeOfDIB =
          dwBmpSize + sizeOf<BITMAPFILEHEADER>() + sizeOf<BITMAPINFOHEADER>();
      bitmapFileHeader.ref.bfOffBits =
          sizeOf<BITMAPFILEHEADER>() + sizeOf<BITMAPINFOHEADER>();

      bitmapFileHeader.ref.bfSize = dwSizeOfDIB;
      bitmapFileHeader.ref.bfType = 0x4D42; // BM

      ///TODO instead of writing to disk take the bitmap directly into memory.
      ///     For now this is easier and not a big performance penalty.
      ///     Though it seems to be the bitmap [lpBitMap] directly from the
      ///     pointer is upside down and blue color is turned yellow.

      final dwBytesWritten = calloc<DWORD>();
      WriteFile(hFile, bitmapFileHeader, sizeOf<BITMAPFILEHEADER>(),
          dwBytesWritten, nullptr);
      WriteFile(hFile, bitmapInfoHeader, sizeOf<BITMAPINFOHEADER>(),
          dwBytesWritten, nullptr);
      WriteFile(hFile, lpBitmap, dwBmpSize, dwBytesWritten, nullptr);

      CloseHandle(hFile);
      var file = File("screen.bmp");
      image = Image.fromBytes(bitmapInfoHeader.ref.biWidth,
          bitmapInfoHeader.ref.biHeight, file.readAsBytesSync());
      file.deleteSync();
    } finally {
      DeleteObject(hdcMemDC);
      ReleaseDC(NULL, hdcScreen);
    }
    return image;
  }

  static Image getSubImage(Image image, int x, int y, int width, int height) {
    return copyCrop(image, x, y, width, height);
  }

  /// Very expensive task for large refImage and smallSubImage.
  /// Especially if they share a lot of the same pixel colors.
  static bool containsSubImage(Image refImage, Image subImage) {
    if (subImage.width > refImage.width || subImage.height > refImage.height) {
      return false;
    }
    for (int row = 0; row < refImage.width - subImage.width; row++) {
      for (int column = 0;
          column < refImage.height - subImage.height;
          column++) {
        var refSubImage =
            refImage.getSubImage(row, column, subImage.width, subImage.height);
        if (refSubImage.equalPixels(subImage)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool equalPixels(Image image1, Image image2) {
    if (image1.data.length != image2.data.length) return false;
    for (int i = 0; i < image1.data.length; i++) {
      if (image1.data[i] != image2.data[i]) {
        return false;
      }
    }
    return true;
  }
}

extension SubImaging on Image {
  Image getSubImage(int x, int y, int width, int height) =>
      ImageUtil.getSubImage(this, x, y, width, height);

  bool containsSubImage(Image subImage) =>
      ImageUtil.containsSubImage(this, subImage);

  bool equalPixels(Image image) => ImageUtil.equalPixels(this, image);
}
