import 'dart:math';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../domain/models/models.dart';
import '../../data/sticker_master.dart';
import '../../data/services/seal_metadata_service.dart';

class SealDetailOverlay extends StatefulWidget {
  const SealDetailOverlay({
    super.key,
    required this.assetPath,
    required this.onClose,
  });

  final String assetPath;
  final VoidCallback onClose;

  @override
  State<SealDetailOverlay> createState() => _SealDetailOverlayState();
}

class _SealDetailOverlayState extends State<SealDetailOverlay>
    with SingleTickerProviderStateMixin {
  SealMetadata? _metadata;
  bool _isLoading = true;
  AnimationController? _rotationController;
  Animation<double>? _rotationAnimation;
  int _rarity = 1;
  late final String _pngPath;
  bool _hasGlb = false;

  @override
  void initState() {
    super.initState();
    _pngPath = StickerCatalog.normalizeAssetPath(widget.assetPath);
    _initAssetInfo();
  }

  @override
  void dispose() {
    _rotationController?.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    final metadata = await SealMetadataService.getMetadata(_pngPath);
    if (!mounted) return;
    setState(() {
      _metadata = metadata;
      _isLoading = false;
      _rarity = metadata?.rarity ?? 1;
    });
  }

  Future<void> _initAssetInfo() async {
    final hasGlb = await StickerCatalog.hasGlbForPng(_pngPath);
    if (!mounted) return;
    setState(() {
      _hasGlb = hasGlb;
    });
    _setupRotationIfNeeded();
    _loadMetadata();
  }

  void _setupRotationIfNeeded() {
    if (_rotationController != null) return;
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: -0.6,
      end: 0.6,
    ).animate(
      CurvedAnimation(
        parent: _rotationController!,
        curve: Curves.easeInOut,
      ),
    );
    _rotationController!.repeat(reverse: true);
  }


  @override
  Widget build(BuildContext context) {
    final isGlb = _hasGlb;

    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: widget.onClose,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 内側のタップで閉じないようにする
            behavior: HitTestBehavior.deferToChild,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ヘッダー（閉じるボタン）
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // 中央揃えのためのスペーサー
                        Expanded(
                          child: _isLoading
                              ? const SizedBox.shrink()
                              : Text(
                                  '${_metadata?.name ?? 'シール'}のシール',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _hasGlb
                          ? 'png: $_pngPath\n glb: ${StickerCatalog.glbPathForPng(_pngPath)}'
                          : 'png: $_pngPath',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // シール画像/3Dモデル
                  Container(
                    width: double.infinity,
                    height: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _rotationAnimation != null
                          ? AnimatedBuilder(
                              animation: _rotationAnimation!,
                              builder: (context, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001) // 遠近感
                                    ..rotateY(_rotationAnimation!.value),
                                  child: isGlb
                                      ? IgnorePointer(
                                          child: ModelViewer(
                                            src: StickerCatalog.glbPathForPng(
                                              _pngPath,
                                            ),
                                            alt: '3D sticker',
                                            autoRotate: false,
                                            disableZoom: true,
                                            cameraControls: false,
                                            backgroundColor: Colors.transparent,
                                            interactionPrompt: InteractionPrompt.none,
                                          ),
                                        )
                                      : Image.asset(
                                          _pngPath,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                );
                              },
                            )
                          : Center(
                              child: Image.asset(
                                _pngPath,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // レア度表示（マスターデータ基準）
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: _RarityStars(rarity: _rarity.clamp(1, 5)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RarityStars extends StatelessWidget {
  const _RarityStars({required this.rarity});

  final int rarity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isFilled = index < rarity;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? const Color(0xFFFFD700) : Colors.grey.shade300,
                size: 24,
              ),
            );
          }),
        ),
      ),
    );
  }
}

