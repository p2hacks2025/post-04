import 'dart:ui';

enum NameplateShape {
  square,
  roundedSquare,
  cloud,
  ribbon,
}

enum FontType {
  rounded,
  handwritten,
}

class PlacedDecoration {
  const PlacedDecoration({
    required this.id,
    required this.type,
    required this.position,
    required this.rotation,
    required this.size,
  });

  final String id;
  final DecorationType type;
  final Offset position;
  final double rotation;
  final double size;

  PlacedDecoration copyWith({
    Offset? position,
    double? rotation,
    double? size,
  }) {
    return PlacedDecoration(
      id: id,
      type: type,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
    );
  }
}

class DecorationType {
  const DecorationType(this.assetPath);
  
  final String assetPath;
  
  static const DecorationType heart = DecorationType('assets/seals/heart.glb');
  static const DecorationType cat = DecorationType('assets/seals/cat.glb');
  static const DecorationType circle = DecorationType('assets/seals/circle.glb');
  static const DecorationType star = DecorationType('assets/seals/star.glb');
  
  static const List<DecorationType> all = [heart, cat, circle, star];
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecorationType &&
          runtimeType == other.runtimeType &&
          assetPath == other.assetPath;

  @override
  int get hashCode => assetPath.hashCode;
}

class NameplateData {
  const NameplateData({
    required this.shape,
    required this.backgroundColor,
    required this.name,
    required this.fontType,
    required this.textColor,
    required this.hasOutline,
    required this.hasShadow,
    required this.decorations,
  });

  final NameplateShape shape;
  final Color backgroundColor;
  final String name;
  final FontType fontType;
  final Color textColor;
  final bool hasOutline;
  final bool hasShadow;
  final List<PlacedDecoration> decorations;

  NameplateData copyWith({
    NameplateShape? shape,
    Color? backgroundColor,
    String? name,
    FontType? fontType,
    Color? textColor,
    bool? hasOutline,
    bool? hasShadow,
    List<PlacedDecoration>? decorations,
  }) {
    return NameplateData(
      shape: shape ?? this.shape,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      name: name ?? this.name,
      fontType: fontType ?? this.fontType,
      textColor: textColor ?? this.textColor,
      hasOutline: hasOutline ?? this.hasOutline,
      hasShadow: hasShadow ?? this.hasShadow,
      decorations: decorations ?? this.decorations,
    );
  }
}
