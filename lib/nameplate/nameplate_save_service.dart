import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:photo_manager/photo_manager.dart';

class NameplateSaveService {
  static Future<bool> saveImage(GlobalKey previewKey) async {
    ui.Image? originalImage;
    ui.Image? resizedImage;
    ui.Picture? picture;
    ui.PictureRecorder? recorder;

    try {
      final RenderRepaintBoundary? boundary =
          previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('画像保存エラー: RepaintBoundaryが見つかりません');
        return false;
      }

      originalImage = await boundary.toImage(pixelRatio: 2.0);

      const squareSize = 1080.0;
      const horizontalPadding = 80.0;
      final availableWidth = squareSize - horizontalPadding * 2;

      recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder!);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, squareSize, squareSize),
        Paint()..color = const ui.Color(0xFFFFF0F5),
      );

      final originalAspect = originalImage.width / originalImage.height;

      double scaledWidth, scaledHeight;
      if (originalAspect > 1.0) {
        scaledWidth = availableWidth;
        scaledHeight = scaledWidth / originalAspect;
      } else {
        scaledWidth = availableWidth;
        scaledHeight = scaledWidth / originalAspect;
      }

      final offsetX = (squareSize - scaledWidth) / 2;
      final offsetY = (squareSize - scaledHeight) / 2;
      final destRect = Rect.fromLTWH(
        offsetX,
        offsetY,
        scaledWidth,
        scaledHeight,
      );

      final paint = Paint()..filterQuality = FilterQuality.high;
      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(
          0,
          0,
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
        destRect,
        paint,
      );

      picture = recorder.endRecording();
      recorder = null;

      resizedImage = await picture!.toImage(
        squareSize.toInt(),
        squareSize.toInt(),
      );

      originalImage.dispose();
      originalImage = null;

      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        debugPrint('画像保存エラー: byteDataがnullです');
        return false;
      }

      final pngBytes = byteData.buffer.asUint8List();

      resizedImage.dispose();
      resizedImage = null;
      picture.dispose();
      picture = null;

      // 権限をリクエスト
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        debugPrint('画像保存エラー: 写真ライブラリへのアクセス権限がありません');
        return false;
      }

      final AssetEntity? entity = await PhotoManager.editor.saveImage(
        pngBytes,
        filename: 'nameplate_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      return entity != null;
    } catch (e, stackTrace) {
      debugPrint('画像保存エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      originalImage?.dispose();
      resizedImage?.dispose();
      picture?.dispose();
      return false;
    }
  }
}
