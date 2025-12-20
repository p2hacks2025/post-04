import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/models.dart';
import '../../domain/constants/nameplate_constants.dart';
import 'package:seal_app/core/widgets/category_tab.dart';
import 'package:seal_app/core/widgets/grid_background.dart';
import 'package:seal_app/features/sticker_book/presentation/widgets/sticker_tile.dart';
import 'package:seal_app/features/sticker_book/data/sticker_master.dart';
import 'package:seal_app/features/sticker_book/presentation/widgets/seal_detail_overlay.dart';

class NameplateTabDecorations extends StatefulWidget {
  const NameplateTabDecorations({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.previewKey,
  });

  final NameplateData data;
  final ValueChanged<NameplateData> onDataChanged;
  final GlobalKey previewKey;

  @override
  State<NameplateTabDecorations> createState() => _NameplateTabDecorationsState();
}

class _NameplateTabDecorationsState extends State<NameplateTabDecorations> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = const ['すべて', 'マーク', 'はこだて', 'ほか'];
  final List<StickerData> _catalog = stickerMasterData;
  late final Map<String, String> _iconByAsset = {
    for (final s in _catalog) s.assetPath: s.iconPath,
  };

  /// アセットパスからファイル名を取得
  String _getFileName(String assetPath) {
    final fileName = assetPath.split('/').last;
    final lastDotIndex = fileName.lastIndexOf('.');
    return lastDotIndex >= 0 ? fileName.substring(0, lastDotIndex) : fileName;
  }

  /// アセットがカテゴリに一致するかチェック
  bool _matchesCategory(String asset, int categoryIndex) {
    final fileName = _getFileName(asset).toLowerCase();

    switch (categoryIndex) {
      case 1: // マーク：heart*, star*, kira*で始まるもの
        return fileName.startsWith('heart') ||
            fileName.startsWith('star') ||
            fileName.startsWith('kira');

      case 2: // はこだて：FUN, hakodateが含まれるもの
        return fileName.contains('fun') || fileName.contains('hakodate');

      case 3: // ほか：上記以外のもの
        final isMark =
            fileName.startsWith('heart') ||
            fileName.startsWith('star') ||
            fileName.startsWith('kira');
        final isHakodate =
            fileName.contains('fun') || fileName.contains('hakodate');
        return !isMark && !isHakodate;

      default:
        return true;
    }
  }

  Future<void> _handleDropSticker(String assetPath, Offset globalPosition) async {
    final previewKey = widget.previewKey;
    final renderBox = previewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final topLeft = renderBox.localToGlobal(Offset.zero);
    final rect = topLeft & renderBox.size;
    if (!rect.contains(globalPosition)) return;

    final local = renderBox.globalToLocal(globalPosition);
    final previewSize = renderBox.size;
    
    if (widget.data.decorations.length >= NameplateColors.maxDecorations) {
      return;
    }

    const defaultSize = 48.0;
    final clamped = Offset(
      local.dx.clamp(defaultSize / 2, previewSize.width - defaultSize / 2),
      local.dy.clamp(defaultSize / 2, previewSize.height - defaultSize / 2),
    );

    final newDecoration = PlacedDecoration(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: DecorationType.fromAssetPath(assetPath),
      position: clamped,
      rotation: 0,
      size: defaultSize,
    );

    widget.onDataChanged(
      widget.data.copyWith(decorations: [...widget.data.decorations, newDecoration]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssets = <String>[];
    for (final sticker in _catalog) {
      if (_selectedCategoryIndex == 0 ||
          _matchesCategory(sticker.assetPath, _selectedCategoryIndex)) {
        filteredAssets.add(sticker.assetPath);
      }
    }

    return Column(
      children: [
        _CategoryTabs(
          categories: _categories,
          selectedIndex: _selectedCategoryIndex,
          onCategorySelected: (index) {
            setState(() {
              _selectedCategoryIndex = index;
            });
          },
        ),
        Expanded(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(right: 1),
                  child: GridBackground(),
                ),
              ),
              GridView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: filteredAssets.length,
                itemBuilder: (context, index) {
                  final assetPath = filteredAssets[index];
                  final displayAsset = _iconByAsset[assetPath] ?? assetPath;
                  return _SealTile(
                    assetPath: assetPath,
                    displayAssetPath: displayAsset,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => SealDetailOverlay(
                          assetPath: assetPath,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      );
                    },
                    onDropSticker: _handleDropSticker,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < categories.length; i++)
              CategoryTab(
                label: categories[i],
                isSelected: selectedIndex == i,
                onTap: () => onCategorySelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _SealTile extends StatefulWidget {
  const _SealTile({
    required this.assetPath,
    required this.displayAssetPath,
    required this.onTap,
    required this.onDropSticker,
  });

  final String assetPath;
  final String displayAssetPath;
  final VoidCallback onTap;
  final void Function(String assetPath, Offset globalPosition) onDropSticker;

  @override
  State<_SealTile> createState() => _SealTileState();
}

class _SealTileState extends State<_SealTile> {
  OverlayEntry? _overlayEntry;
  Offset _overlayPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDragging = false;
  }

  void _showOverlay(
    BuildContext context,
    String assetPath,
    Offset globalPosition,
  ) {
    _overlayPosition = globalPosition;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final isGlb = assetPath.toLowerCase().endsWith('.glb');
        return Positioned(
          left: _overlayPosition.dx - 30,
          top: _overlayPosition.dy - 30,
          child: Material(
            color: Colors.transparent,
            child: StickerTile(
              assetPath: assetPath,
              size: 60,
              showShadow: false,
              showBackground: false,
              forceStaticImage: false,
              useModelViewer: isGlb,
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = widget.assetPath;
    final tileAssetPath = widget.displayAssetPath;
    final isGlb = tileAssetPath.toLowerCase().endsWith('.glb');

    final tile = StickerTile(
      assetPath: tileAssetPath,
      forceStaticImage: false,
      useModelViewer: isGlb,
      showBackground: false,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPressStart: (details) {
        if (_isDragging) return;
        HapticFeedback.lightImpact();
        setState(() => _isDragging = true);
        _showOverlay(context, tileAssetPath, details.globalPosition);
      },
      onLongPressMoveUpdate: (details) {
        if (_overlayEntry == null) return;
        _overlayPosition = details.globalPosition;
        _overlayEntry!.markNeedsBuild();
      },
      onLongPressEnd: (details) {
        final dropPosition = details.globalPosition;
        _removeOverlay();
        setState(() {});
        widget.onDropSticker(assetPath, dropPosition);
      },
      child: Opacity(opacity: _isDragging ? 0.5 : 1, child: tile),
    );
  }
}

