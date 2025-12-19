import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../domain/constants/nameplate_constants.dart';
import '../../data/services/nameplate_save_service.dart';
import '../widgets/nameplate_preview.dart';
import '../widgets/nameplate_tabs.dart';
import '../../../../core/utils/error_handler.dart';

class NameplateEditorPage extends StatefulWidget {
  const NameplateEditorPage({super.key});

  @override
  State<NameplateEditorPage> createState() => _NameplateEditorPageState();
}

class _NameplateEditorPageState extends State<NameplateEditorPage> {
  int _selectedTabIndex = 0;
  NameplateData _nameplateData = NameplateData(
    shape: NameplateShape.roundedSquare,
    backgroundColor: NameplateColors.backgroundColors[0],
    name: '',
    fontType: FontType.rounded,
    textColor: const Color(0xFFFF6FAE),
    hasOutline: true,
    hasShadow: true,
    decorations: [],
  );

  void _updateNameplate(NameplateData newData) {
    setState(() {
      _nameplateData = newData;
    });
  }

  void _resetNameplate() {
    setState(() {
      _nameplateData = NameplateData(
        shape: NameplateShape.roundedSquare,
        backgroundColor: NameplateColors.backgroundColors[0],
        name: '',
        fontType: FontType.rounded,
        textColor: const Color(0xFFFF6FAE),
        hasOutline: true,
        hasShadow: true,
        decorations: [],
      );
      _selectedTabIndex = 0;
    });
  }

  Future<void> _onSave() async {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final success = await NameplateSaveService.saveImage(_previewKey);

      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ErrorHandler.showSuccessSnackBar(context, 'ネームプレートを保存しました！');
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            '保存に失敗しました。写真ライブラリへのアクセス権限を確認してください。',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NameplateColors.backgroundColors[0],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: NameplateColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: NameplateColors.accentPrimary,
            ),
            onPressed: _resetNameplate,
            tooltip: 'リセット',
          ),
          IconButton(
            icon: const Icon(Icons.save, color: NameplateColors.accentPrimary),
            onPressed: _onSave,
            tooltip: '保存',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = 32.0;
            final estimatedAspectRatio = 3.0;
            final estimatedPreviewHeight =
                (constraints.maxWidth - horizontalPadding) /
                    estimatedAspectRatio +
                16;
            final availableForTabs =
                (constraints.maxHeight - estimatedPreviewHeight - 24).clamp(
                  280.0,
                  constraints.maxHeight * 0.7,
                );

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: RepaintBoundary(
                        key: _previewKey,
                        child: NameplatePreview(
                          data: _nameplateData,
                          onDecorationMoved: (id, position) {
                            final updatedDecorations = _nameplateData
                                .decorations
                                .map((dec) {
                                  if (dec.id == id) {
                                    return dec.copyWith(position: position);
                                  }
                                  return dec;
                                })
                                .toList();
                            _updateNameplate(
                              _nameplateData.copyWith(
                                decorations: updatedDecorations,
                              ),
                            );
                          },
                          onDecorationRemoved: (id) {
                            final updatedDecorations = _nameplateData
                                .decorations
                                .where((dec) => dec.id != id)
                                .toList();
                            _updateNameplate(
                              _nameplateData.copyWith(
                                decorations: updatedDecorations,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: availableForTabs,
                      child: NameplateTabs(
                        selectedIndex: _selectedTabIndex,
                        nameplateData: _nameplateData,
                        onTabChanged: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        onDataChanged: _updateNameplate,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  final GlobalKey _previewKey = GlobalKey();
}
