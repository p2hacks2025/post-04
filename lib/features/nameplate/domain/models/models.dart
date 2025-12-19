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

  Map<String, dynamic> toJson() => {
        'id': id,
        'assetPath': type.assetPath,
        'dx': position.dx,
        'dy': position.dy,
        'rotation': rotation,
        'size': size,
      };

  factory PlacedDecoration.fromJson(Map<String, dynamic> json) {
    return PlacedDecoration(
      id: json['id'] as String,
      type: DecorationType.fromAssetPath(json['assetPath'] as String),
      position: Offset(
        (json['dx'] as num).toDouble(),
        (json['dy'] as num).toDouble(),
      ),
      rotation: (json['rotation'] as num).toDouble(),
      size: (json['size'] as num).toDouble(),
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

  static DecorationType fromAssetPath(String assetPath) {
    for (final t in all) {
      if (t.assetPath == assetPath) return t;
    }
    return DecorationType(assetPath);
  }
  
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

  Map<String, dynamic> toJson() => {
        'shape': shape.index,
      'backgroundColor': backgroundColor.toARGB32(),
        'name': name,
        'fontType': fontType.index,
      'textColor': textColor.toARGB32(),
        'hasOutline': hasOutline,
        'hasShadow': hasShadow,
        'decorations': decorations.map((e) => e.toJson()).toList(),
      };

  factory NameplateData.fromJson(Map<String, dynamic> json) {
    return NameplateData(
      shape: NameplateShape.values[(json['shape'] as num).toInt()],
      backgroundColor: Color((json['backgroundColor'] as num).toInt()),
      name: (json['name'] as String?) ?? '',
      fontType: FontType.values[(json['fontType'] as num).toInt()],
      textColor: Color((json['textColor'] as num).toInt()),
      hasOutline: (json['hasOutline'] as bool?) ?? true,
      hasShadow: (json['hasShadow'] as bool?) ?? true,
      decorations: ((json['decorations'] as List?) ?? const [])
          .map((e) => PlacedDecoration.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
