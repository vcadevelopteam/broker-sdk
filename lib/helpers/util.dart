import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class Utils {
  static retryFuture(future, delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<List<PlatformFile>> compressImages(
      List<PlatformFile> imagesToCompress) async {
    List<PlatformFile> imagesCompressed = [];
    for (var element in imagesToCompress) {
      final mimeType = lookupMimeType(element.path!);

      if (mimeType!.contains("jpg") ||
          mimeType.contains("jpeg") ||
          mimeType.contains("png") ||
          mimeType.contains("tiff") ||
          mimeType.contains("svg")) {
        File compressedFile =
            await FlutterNativeImage.compressImage(element.path!, quality: 80);
        var fileName = path.basename(compressedFile.path);
        imagesCompressed.add(PlatformFile(
            name: fileName,
            size: compressedFile.lengthSync(),
            path: element.path));
      } else {
        imagesCompressed.add(element);
      }
    }
    return Future.value(imagesCompressed);
  }
}
