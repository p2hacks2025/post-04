import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../domain/constants/nameplate_constants.dart';
import '../../data/repositories/nameplate_storage.dart';
import '../../data/services/nameplate_save_service.dart';
import '../widgets/nameplate_preview.dart';
import '../widgets/nameplate_tabs.dart';

class NameplateEditorPage extends StatefulWidget {
  const NameplateEditorPage({super.key});

  @override
  State<NameplateEditorPage> createState() => _NameplateEditorPageState();
}

class _NameplateEditorPageState extends State<NameplateEditorPage> {
  int _selectedTabIndex = 0;
  bool _allowPop = false;
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

  Timer? _autosaveTimer;
  static const Duration _autosaveDebounce = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _loadSavedNameplate();
  }

  Future<void> _loadSavedNameplate() async {
    final saved = await NameplateStorage.load();
    if (!mounted) return;
    if (saved != null) {
      setState(() => _nameplateData = saved);
    }
  }

  void _updateNameplate(NameplateData newData) {
    setState(() {
      _nameplateData = newData;
    });

    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, () {
      // 自動保存は「設定(JSON)」のみ。画像保存は明示的な保存ボタンで行う。
      unawaited(NameplateStorage.save(_nameplateData));
    });
  }

  Future<void> _saveSettingsNow() async {
    _autosaveTimer?.cancel();
    await NameplateStorage.save(_nameplateData);
  }

  Future<void> _saveThenPop() async {
    await _saveSettingsNow();
    if (!mounted) return;

    setState(() {
      _allowPop = true;
    });

    Navigator.of(context).pop();
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

    final success = await NameplateSaveService.saveImage(_previewKey);
    await NameplateStorage.save(_nameplateData);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '保存しました！' : '保存に失敗しました（ネームプレート設定は保存済み）'),
          backgroundColor: success ? NameplateColors.accentSuccess : Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    // 画面が閉じるタイミングでもベストエフォートで保存
    unawaited(NameplateStorage.save(_nameplateData));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveThenPop();
      },
      child: Scaffold(
        backgroundColor: NameplateColors.backgroundColors[0],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: NameplateColors.textPrimary,
            ),
            onPressed: _saveThenPop,
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
              icon:
                  const Icon(Icons.save, color: NameplateColors.accentPrimary),
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
                          previewKey: _previewKey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  final GlobalKey _previewKey = GlobalKey();
}
