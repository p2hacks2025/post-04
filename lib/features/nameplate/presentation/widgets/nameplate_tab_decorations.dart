import 'dart:math';
import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../domain/constants/nameplate_constants.dart';
import 'package:seal_app/core/widgets/category_tab.dart';
import 'package:seal_app/core/widgets/grid_background.dart';
import 'package:seal_app/features/sticker_book/presentation/widgets/sticker_tile.dart';
import 'package:seal_app/features/sticker_book/data/sticker_master.dart';

class NameplateTabDecorations extends StatefulWidget {
  const NameplateTabDecorations({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final NameplateData data;
  final ValueChanged<NameplateData> onDataChanged;

  @override
  State<NameplateTabDecorations> createState() => _NameplateTabDecorationsState();
}

class _NameplateTabDecorationsState extends State<NameplateTabDecorations> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = const ['すべて', 'どうぶつ', 'のりもの', 'たべもの'];
  List<DecorationType> _decorations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDecorations();
  }

  Future<void> _loadDecorations() async {
    final catalog = await StickerCatalog.load();
    if (!mounted) return;
    setState(() {
      _decorations = catalog.map((s) => DecorationType(s.assetPath)).toList();
      _loading = false;
    });
  }

  void _addDecoration(DecorationType type) {
    if (widget.data.decorations.length >= NameplateColors.maxDecorations) {
      return;
    }

    final random = Random();
    final newDecoration = PlacedDecoration(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      position: Offset(
        random.nextDouble() * 200 + 100,
        random.nextDouble() * 200 + 100,
      ),
      rotation: (random.nextDouble() - 0.5) * 0.35,
      size: 32 + random.nextDouble() * 16,
    );

    widget.onDataChanged(
      widget.data.copyWith(decorations: [...widget.data.decorations, newDecoration]),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: _decorations.length,
                itemBuilder: (context, index) {
                  final type = _decorations[index];
                  return _SealTile(type: type, onTap: () => _addDecoration(type));
                },
              ),
              if (_loading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
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
        padding: const EdgeInsets.only(left: 0, right: 0),
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

class _SealTile extends StatelessWidget {
  const _SealTile({required this.type, required this.onTap});

  final DecorationType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: StickerTile(
        assetPath: type.assetPath,
      ),
    );
  }
}

