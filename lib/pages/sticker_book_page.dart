import 'package:flutter/material.dart';

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({super.key});

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage> {
  final List<String> _categories = const ['すべて', 'どうぶつ', 'のりもの', 'たべもの'];
  int _selectedCategoryIndex = 0;

  final List<String> _stickers = List.filled(12, 'assets/icons/home_icon.png');
  final PageController _pageController = PageController();

  final List<List<Color>> _boardGradients = const [
    [Color(0xFFD888FF), Color(0xFFF9C4E6)],
    [Color(0xFFB2E0FF), Color(0xFFFBD3FF)],
    [Color(0xFFFFE5B5), Color(0xFFF8C4E1)],
    [Color(0xFFBFE3D0), Color(0xFFD8C8FF)],
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _StickerBookPager(
              controller: _pageController,
              gradients: _boardGradients,
            ),
            const SizedBox(height: 12),
            const Spacer(),
          ],
        ),
        _StickerListBottomSheet(
          categories: _categories,
          selectedIndex: _selectedCategoryIndex,
          onCategorySelected: (index) {
            setState(() => _selectedCategoryIndex = index);
          },
          stickers: _stickers,
        ),
      ],
    );
  }
}

class _StickerBookPager extends StatelessWidget {
  const _StickerBookPager({required this.controller, required this.gradients});

  final PageController controller;
  final List<List<Color>> gradients;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFF8F0);
    return SizedBox(
      height: 480,
      child: PageView.builder(
        controller: controller,
        itemCount: gradients.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _StickerBoardPage(
            gradient: gradients[index % gradients.length],
            backgroundColor: backgroundColor,
          );
        },
      ),
    );
  }
}

class _StickerBoardPage extends StatelessWidget {
  const _StickerBoardPage({
    required this.gradient,
    required this.backgroundColor,
  });

  final List<Color> gradient;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 32,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (_) => Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickerListBottomSheet extends StatelessWidget {
  const _StickerListBottomSheet({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.stickers,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;
  final List<String> stickers;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
          child: Column(
            children: [
              _StickerTabs(
                categories: categories,
                selectedIndex: selectedIndex,
                onCategorySelected: onCategorySelected,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _StickerGridArea(
                  stickers: stickers,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StickerTabs extends StatelessWidget {
  const _StickerTabs({
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
        child: Transform.translate(
          offset: const Offset(0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (var i = 0; i < categories.length; i++)
                _FileTab(
                  label: categories[i],
                  isSelected: selectedIndex == i,
                  onTap: () => onCategorySelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerGridArea extends StatelessWidget {
  const _StickerGridArea({
    required this.stickers,
    required this.scrollController,
  });

  final List<String> stickers;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(right: 1),
              child: _GridBackground(),
            ),
          ),
          GridView.builder(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: stickers.length,
            itemBuilder: (context, index) {
              return _StickerTile(assetPath: stickers[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _FileTab extends StatelessWidget {
  const _FileTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (_) => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE8D9) : const Color(0xFFF1F5F9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border(
            top: BorderSide(
              color: isSelected
                  ? const Color(0xFFC6845A)
                  : const Color(0xFFCBD5E1),
              width: 2,
            ),
            left: BorderSide(
              color: isSelected
                  ? const Color(0xFFC6845A)
                  : const Color(0xFFCBD5E1),
              width: 2,
            ),
            right: BorderSide(
              color: isSelected
                  ? const Color(0xFFC6845A)
                  : const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFC6845A)
                : const Color(0xFF334155),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(assetPath, filterQuality: FilterQuality.high),
    );
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridBackgroundPainter());
  }
}

class _GridBackgroundPainter extends CustomPainter {
  const _GridBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double step = 24;
    final paint = Paint()
      ..color = const Color(0xFFD9DDE3)
      ..strokeWidth = 1;

    final double width = size.width;
    final double height = size.height;

    for (double x = 0; x <= width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }
    for (double y = 0; y <= height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
