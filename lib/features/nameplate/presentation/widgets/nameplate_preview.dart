import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/models.dart';
import 'package:seal_app/features/sticker_book/presentation/widgets/sticker_tile.dart';

class NameplatePreview extends StatelessWidget {
  const NameplatePreview({
    super.key,
    required this.data,
    this.onDecorationMoved,
    this.onDecorationRemoved,
  });

  final NameplateData data;
  final void Function(String id, Offset position)? onDecorationMoved;
  final void Function(String id)? onDecorationRemoved;

  @override
  Widget build(BuildContext context) {
    return _NameplateCard(
      data: data,
      onDecorationMoved: onDecorationMoved,
      onDecorationRemoved: onDecorationRemoved,
    );
  }
}

class _NameplateCard extends StatefulWidget {
  const _NameplateCard({
    required this.data,
    this.onDecorationMoved,
    this.onDecorationRemoved,
  });

  final NameplateData data;
  final void Function(String id, Offset position)? onDecorationMoved;
  final void Function(String id)? onDecorationRemoved;

  @override
  State<_NameplateCard> createState() => _NameplateCardState();
}

class _NameplateCardState extends State<_NameplateCard> {
  double? _imageAspectRatio;
  ImageStreamListener? _imageStreamListener;
  ImageStream? _imageStream;

  @override
  void initState() {
    super.initState();
    _loadImageAspectRatio();
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    super.dispose();
  }

  void _loadImageAspectRatio() {
    final imagePath = _getBackgroundImagePath(
      widget.data.shape,
      widget.data.backgroundColor,
    );
    final imageProvider = AssetImage(imagePath);
    _imageStream = imageProvider.resolve(const ImageConfiguration());
    _imageStreamListener = ImageStreamListener((ImageInfo info, bool _) {
      if (mounted) {
        setState(() {
          _imageAspectRatio = info.image.width / info.image.height;
        });
      }
    });
    _imageStream!.addListener(_imageStreamListener!);
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getBackgroundImagePath(
      widget.data.shape,
      widget.data.backgroundColor,
    );
    final aspectRatio = _imageAspectRatio ?? 3.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: widget.data.backgroundColor);
                      },
                    ),
                  ),
                  ...widget.data.decorations.map(
                    (dec) => _DecorationWidget(
                      decoration: dec,
                      cardSize: cardSize,
                      onMoved: widget.onDecorationMoved != null
                          ? (id, position) =>
                                widget.onDecorationMoved!(id, position)
                          : null,
                      onRemoved: widget.onDecorationRemoved != null
                          ? (id) => widget.onDecorationRemoved!(id)
                          : null,
                    ),
                  ),
                  IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: cardSize.height * 0.15,
                          left: 32,
                          right: 24,
                        ),
                        child: _NameText(
                          name: widget.data.name,
                          fontType: widget.data.fontType,
                          textColor: widget.data.textColor,
                          hasOutline: widget.data.hasOutline,
                          hasShadow: widget.data.hasShadow,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getBackgroundImagePath(NameplateShape shape, Color backgroundColor) {
    return 'assets/name-plates/name-plate-pink.png';
  }
}

class _NameText extends StatelessWidget {
  const _NameText({
    required this.name,
    required this.fontType,
    required this.textColor,
    required this.hasOutline,
    required this.hasShadow,
  });

  final String name;
  final FontType fontType;
  final Color textColor;
  final bool hasOutline;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty) {
      return Text(
        'なまえ',
        style: _getTextStyle(
          fontType,
          24,
        ).copyWith(color: const Color(0xFFFF6FAE)),
      );
    }

    final fontSize = _calculateFontSize(name.length);
    final baseStyle = _getTextStyle(fontType, fontSize);
    final textStyle = baseStyle.copyWith(
      shadows: hasShadow
          ? [
              Shadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );

    if (hasOutline) {
      return Stack(
        children: [
          Text(
            name,
            style: textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Colors.white,
            ),
          ),
          Text(name, style: textStyle),
        ],
      );
    }

    return Text(name, style: textStyle);
  }

  TextStyle _getTextStyle(FontType fontType, double fontSize) {
    switch (fontType) {
      case FontType.rounded:
        return GoogleFonts.mPlusRounded1c(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        );
      case FontType.handwritten:
        return GoogleFonts.yomogi(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        );
    }
  }

  double _calculateFontSize(int length) {
    return 60;
  }
}

class _DecorationWidget extends StatefulWidget {
  const _DecorationWidget({
    required this.decoration,
    required this.cardSize,
    this.onMoved,
    this.onRemoved,
  });

  final PlacedDecoration decoration;
  final Size cardSize;
  final void Function(String id, Offset position)? onMoved;
  final void Function(String id)? onRemoved;

  @override
  State<_DecorationWidget> createState() => _DecorationWidgetState();
}

class _DecorationWidgetState extends State<_DecorationWidget> {
  @override
  Widget build(BuildContext context) {
    final halfSize = widget.decoration.size / 2;
    final clampedX = widget.decoration.position.dx.clamp(
      halfSize,
      widget.cardSize.width - halfSize,
    );
    final clampedY = widget.decoration.position.dy.clamp(
      halfSize,
      widget.cardSize.height - halfSize,
    );

    return Positioned(
      left: clampedX - halfSize,
      top: clampedY - halfSize,
      child: GestureDetector(
        onPanUpdate: widget.onMoved != null
            ? (details) {
                final renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox == null) return;
                final stackBox = renderBox.parent as RenderBox?;
                if (stackBox == null) return;
                final localPosition = stackBox.globalToLocal(
                  details.globalPosition,
                );
                final halfSize = widget.decoration.size / 2;
                final clampedPosition = Offset(
                  localPosition.dx.clamp(
                    halfSize,
                    widget.cardSize.width - halfSize,
                  ),
                  localPosition.dy.clamp(
                    halfSize,
                    widget.cardSize.height - halfSize,
                  ),
                );
                widget.onMoved!(widget.decoration.id, clampedPosition);
              }
            : null,
        onLongPress: widget.onRemoved != null
            ? () => widget.onRemoved!(widget.decoration.id)
            : null,
        child: Transform.rotate(
          angle: widget.decoration.rotation,
          child: SizedBox(
            width: widget.decoration.size,
            height: widget.decoration.size,
            child: _getDecorationIcon(widget.decoration.type),
          ),
        ),
      ),
    );
  }

  Widget _getDecorationIcon(DecorationType type) {
    return StickerTile(
      assetPath: type.assetPath,
      size: widget.decoration.size,
      showShadow: false,
      forceStaticImage: true,
    );
  }
}
