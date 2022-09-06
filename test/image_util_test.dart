import 'package:image/image.dart';
import 'package:inputter/src/image_util.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('ImageUtil tests', () {

    Image? image;

    test('Capture image of whole screen', () {
      var before = DateTime.now();
      image = ImageUtil.captureImage();
      print(
          'ImageUtil.captureImage() took ${DateTime.now().difference(before).inMilliseconds} ms.');
      expect(true, image != null);
    });

    test('Contains own subImage', () {
      var before = DateTime.now();
      var subImage = ImageUtil.getSubImage(image!, 100, 100, 100, 100);
      var containsSubImage = ImageUtil.containsSubImage(image!, subImage);
      print(
          '"Contains own subImage" test took ${DateTime.now().difference(before).inMilliseconds} ms.');
      expect(true, containsSubImage);
    });

    test('Image does not contain larger subImage', () {
      var image2 = Image.fromBytes(5000, 5000, []);
      expect(false, image!.containsSubImage(image2));
    });
  });
}
