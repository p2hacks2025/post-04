import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../data/sticker_master.dart';

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
  AnimationController? _rotationController;
  Animation<double>? _rotationAnimation;
  StickerData? _sticker;
  int _rarity = 1;

  @override
  void initState() {
    super.initState();
    // マスターデータから表示情報を決定（同期）
    _sticker = _getStickerFromMaster(widget.assetPath);
    _rarity = (_sticker?.rarity ?? 1).clamp(1, 5);
    final isGlb = widget.assetPath.toLowerCase().endsWith('.glb');
    if (isGlb) {
      _rotationController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      );
      _rotationAnimation =
          Tween<double>(
            begin: -0.785398, // -45度（ラジアン）
            end: 0.785398, // +45度（ラジアン）
          ).animate(
            CurvedAnimation(
              parent: _rotationController!,
              curve: Curves.easeInOut,
            ),
          );
      _rotationController!.repeat(reverse: true);
    }
  }

  StickerData? _getStickerFromMaster(String assetPath) {
    try {
      return stickerMasterData.firstWhere((e) => e.assetPath == assetPath);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _rotationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGlb = widget.assetPath.toLowerCase().endsWith('.glb');

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
                          child: Text(
                            '${_sticker?.name ?? 'シール'}のシール',
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
                  // シール画像/3Dモデル
                  Container(
                    width: double.infinity,
                    height: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: isGlb && _rotationAnimation != null
                          ? AnimatedBuilder(
                              animation: _rotationAnimation!,
                              builder: (context, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001) // 遠近感
                                    ..rotateY(_rotationAnimation!.value),
                                  child: ModelViewer(
                                    src: widget.assetPath,
                                    alt: '3D sticker',
                                    autoRotate: false,
                                    disableZoom: true,
                                    cameraControls: false,
                                    backgroundColor: Colors.transparent,
                                    interactionPrompt: InteractionPrompt.none,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Image.asset(
                                widget.assetPath,
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
                color: isFilled
                    ? const Color(0xFFFFD700)
                    : Colors.grey.shade300,
                size: 24,
              ),
            );
          }),
        ),
      ),
    );
  }
}
