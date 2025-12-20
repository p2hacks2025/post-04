class StickerAssetPaths {
  static const String sealsDir = 'assets/seals/';

  static bool isSealAsset(String path) => path.startsWith(sealsDir);

  static bool isPng(String path) => path.toLowerCase().endsWith('.png');

  static bool isGlb(String path) => path.toLowerCase().endsWith('.glb');

  static String normalizeToPng(String path) {
    if (isGlb(path)) {
      return path.replaceAll(RegExp(r'\.glb$', caseSensitive: false), '.png');
    }
    return path;
  }

  static String toGlb(String pngPath) {
    return pngPath.replaceAll(RegExp(r'\.png$', caseSensitive: false), '.glb');
  }

  static String baseName(String path) {
    final fileName = path.split('/').last;
    return fileName.replaceAll(RegExp(r'\.(png|glb)$', caseSensitive: false), '');
  }
}
