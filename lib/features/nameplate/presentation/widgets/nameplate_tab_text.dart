import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/models.dart';
import '../../domain/constants/nameplate_constants.dart';

class NameplateTabText extends StatefulWidget {
  const NameplateTabText({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final NameplateData data;
  final ValueChanged<NameplateData> onDataChanged;

  @override
  State<NameplateTabText> createState() => _NameplateTabTextState();
}

class _NameplateTabTextState extends State<NameplateTabText> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('なまえ'),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            maxLength: NameplateColors.maxNameLength,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[あ-ん]*$')),
            ],
            decoration: InputDecoration(
              hintText: 'ひらがな5文字',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (value) {
              final filtered = value.replaceAll(RegExp(r'[^あ-ん]'), '');
              final limited = filtered.length > NameplateColors.maxNameLength
                  ? filtered.substring(0, NameplateColors.maxNameLength)
                  : filtered;
              if (limited != value) {
                _nameController.value = TextEditingValue(
                  text: limited,
                  selection: TextSelection.collapsed(offset: limited.length),
                );
              }
              widget.onDataChanged(widget.data.copyWith(name: limited));
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('フォント'),
          const SizedBox(height: 12),
          _FontSelector(
            selected: widget.data.fontType,
            onSelected: (fontType) {
              widget.onDataChanged(widget.data.copyWith(fontType: fontType));
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('いろ'),
          const SizedBox(height: 12),
          _TextColorSelector(
            selected: widget.data.textColor,
            onSelected: (color) {
              widget.onDataChanged(widget.data.copyWith(textColor: color));
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('そうしょく'),
          const SizedBox(height: 12),
          _DecorationOptions(
            hasOutline: widget.data.hasOutline,
            hasShadow: widget.data.hasShadow,
            onOutlineChanged: (value) {
              widget.onDataChanged(widget.data.copyWith(hasOutline: value));
            },
            onShadowChanged: (value) {
              widget.onDataChanged(widget.data.copyWith(hasShadow: value));
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.zenMaruGothic(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: NameplateColors.textPrimary,
      ),
    );
  }
}

class _FontSelector extends StatelessWidget {
  const _FontSelector({required this.selected, required this.onSelected});

  final FontType selected;
  final ValueChanged<FontType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FontOption(
          fontType: FontType.rounded,
          label: 'まるっぽい',
          preview: 'あ',
          isSelected: selected == FontType.rounded,
          onTap: () => onSelected(FontType.rounded),
        ),
        _FontOption(
          fontType: FontType.handwritten,
          label: 'てがきっぽい',
          preview: 'あ',
          isSelected: selected == FontType.handwritten,
          onTap: () => onSelected(FontType.handwritten),
        ),
      ],
    );
  }
}

class _FontOption extends StatelessWidget {
  const _FontOption({
    required this.fontType,
    required this.label,
    required this.preview,
    required this.isSelected,
    required this.onTap,
  });

  final FontType fontType;
  final String label;
  final String preview;
  final bool isSelected;
  final VoidCallback onTap;

  TextStyle _getTextStyle() {
    switch (fontType) {
      case FontType.rounded:
        return GoogleFonts.mPlusRounded1c(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        );
      case FontType.handwritten:
        return GoogleFonts.yomogi(fontSize: 24, fontWeight: FontWeight.bold);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? NameplateColors.accentPrimary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? NameplateColors.accentPrimary
                : NameplateColors.textSubtle.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              preview,
              style: _getTextStyle().copyWith(
                color: isSelected
                    ? NameplateColors.accentPrimary
                    : NameplateColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.zenMaruGothic(
                fontSize: 12,
                color: isSelected
                    ? NameplateColors.accentPrimary
                    : NameplateColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextColorSelector extends StatelessWidget {
  const _TextColorSelector({required this.selected, required this.onSelected});

  final Color selected;
  final ValueChanged<Color> onSelected;

  static const List<Color> textColors = [
    Color(0xFFFF6FAE),
    Colors.white,
    NameplateColors.textPrimary,
    Color(0xFF7B9CFF),
    Color(0xFF7ED9A4),
    Color(0xFFFFB84D),
    Color(0xFF9B7ED9),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: textColors.map((color) {
        final isSelected = color.value == selected.value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onSelected(color);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? NameplateColors.accentPrimary
                    : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: NameplateColors.accentPrimary.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DecorationOptions extends StatelessWidget {
  const _DecorationOptions({
    required this.hasOutline,
    required this.hasShadow,
    required this.onOutlineChanged,
    required this.onShadowChanged,
  });

  final bool hasOutline;
  final bool hasShadow;
  final ValueChanged<bool> onOutlineChanged;
  final ValueChanged<bool> onShadowChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleOption(
            label: 'ふちあり',
            isSelected: hasOutline,
            onTap: () => onOutlineChanged(!hasOutline),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleOption(
            label: 'かげ',
            isSelected: hasShadow,
            onTap: () => onShadowChanged(!hasShadow),
          ),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? NameplateColors.accentPrimary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? NameplateColors.accentPrimary
                : NameplateColors.textSubtle.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.zenMaruGothic(
              fontSize: 14,
              color: isSelected
                  ? NameplateColors.accentPrimary
                  : NameplateColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
