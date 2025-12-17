import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';
import 'nameplate_constants.dart';
import 'nameplate_tab_text.dart';
import 'nameplate_tab_decorations.dart';

class NameplateTabs extends StatelessWidget {
  const NameplateTabs({
    super.key,
    required this.selectedIndex,
    required this.nameplateData,
    required this.onTabChanged,
    required this.onDataChanged,
  });

  final int selectedIndex;
  final NameplateData nameplateData;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<NameplateData> onDataChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // タブバー
        Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TabButton(
                icon: Icons.text_fields,
                label: 'もじ',
                isSelected: selectedIndex == 0,
                onTap: () => onTabChanged(0),
              ),
              _TabButton(
                icon: Icons.auto_awesome,
                label: 'シール',
                isSelected: selectedIndex == 1,
                onTap: () => onTabChanged(1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // タブコンテンツ
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                child: _buildTabContent(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return NameplateTabText(
          data: nameplateData,
          onDataChanged: onDataChanged,
        );
      case 1:
        return NameplateTabDecorations(
          data: nameplateData,
          onDataChanged: onDataChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? NameplateColors.accentPrimary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? NameplateColors.accentPrimary
                  : NameplateColors.textSubtle,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.zenMaruGothic(
                fontSize: 12,
                color: isSelected
                    ? NameplateColors.accentPrimary
                    : NameplateColors.textSubtle,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
