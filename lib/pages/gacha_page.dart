import 'dart:math';
import 'package:flutter/material.dart';
import 'package:seal_app/data/sticker_master.dart';
import 'package:seal_app/services/sticker_count_store.dart';
import 'package:seal_app/sticker_book/sticker_tile.dart';

class GachaPage extends StatefulWidget {
  const GachaPage({super.key, this.rarityWeights});

  // レア度→重み（大きいほど出やすい）。未指定ならデフォルト
  final Map<int, double>? rarityWeights;

  @override
  State<GachaPage> createState() => _GachaPageState();
}

enum _GachaPhase { idle, animating, result }

class _GachaPageState extends State<GachaPage> with SingleTickerProviderStateMixin {
  final _rand = Random();
  late final StickerCountStore _countStore;
  late final List<StickerData> _catalog;
  late final Map<int, double> _weights = widget.rarityWeights ?? {
    1: 50, 2: 30, 3: 15, 4: 4, 5: 1,
  };

  _GachaPhase _phase = _GachaPhase.idle;
  StickerData? _result;
  bool _isNew = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400), // 2.4秒のタメ
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) _revealResult();
    });

  @override
  void initState() {
    super.initState();
    _catalog = List.of(stickerMasterDb)..sort((a, b) => a.number.compareTo(b.number));
    _countStore = StickerCountStore(_catalog.map((e) => e.assetPath).toList());
    _init();
  }

  Future<void> _init() async {
    await _countStore.loadOrInit();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGacha() {
    if (_phase == _GachaPhase.animating) return;
    setState(() {
      _phase = _GachaPhase.animating;
      _result = null;
    });
    _controller.forward(from: 0);
  }

  Future<void> _revealResult() async {
    final picked = _rollSticker();
    final before = _countStore.getCount(picked.assetPath);
    await _countStore.inc(picked.assetPath);
    setState(() {
      _result = picked;
      _isNew = before == 0;
      _phase = _GachaPhase.result;
    });
  }

  StickerData _rollSticker() {
    // 1) レア度を重み付きで抽選
    final raritySet = _catalog.map((s) => s.rarity).toSet();
    final entries = raritySet.map((r) => MapEntry(r, _weights[r] ?? 1)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    double p = _rand.nextDouble() * total;
    int chosenRarity = entries.first.key;
    for (final e in entries) {
      if (p < e.value) {
        chosenRarity = e.key;
        break;
      }
      p -= e.value;
    }

    // 2) 選ばれたレア度からシールをランダムに1つ
    final candidates = _catalog.where((s) => s.rarity == chosenRarity).toList();
    if (candidates.isEmpty) return _catalog[_rand.nextInt(_catalog.length)];
    return candidates[_rand.nextInt(candidates.length)];
  }

  @override
  Widget build(BuildContext context) {
    final isAnimating = _phase == _GachaPhase.animating;

    // かわいい箱の演出（ゆらゆら＋ぷにっと拡縮＋キラキラ）

    return Scaffold(
      appBar: AppBar(title: const Text('ガチャ')),
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 箱
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // 進捗 0→1 をふんわり揺らす・光らす
                final t = _controller.value;
                final angle = sin(t * pi * 4) * 0.16; // 4周期でふりふり
                final scale = 1.0 + sin(t * pi * 2) * 0.05; // 2周期でぷにっ
                final glowAlpha = (sin(t * pi * 2) * 0.5 + 0.5) * 0.6; // 0.0-0.6

                return Transform.rotate(
                  angle: angle,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD9A8), Color(0xFFFFBBD1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withValues(alpha: glowAlpha),
                            blurRadius: 30 * glowAlpha,
                            spreadRadius: 6 * glowAlpha,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.card_giftcard, size: 64, color: Color(0xFF8A4F34)),
                      ),
                    ),
                  ),
                );
              },
            ),
            // 結果表示
            if (_phase == _GachaPhase.result && _result != null)
              _ResultCard(
                sticker: _result!,
                isNew: _isNew,
                ownedCount: _countStore.getCount(_result!.assetPath),
                onClose: () => setState(() => _phase = _GachaPhase.idle),
                onAgain: () {
                  setState(() => _phase = _GachaPhase.idle);
                  _startGacha();
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: isAnimating ? null : _startGacha,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC6845A),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            child: Text(isAnimating ? '抽選中...' : 'ガチャをひく'),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.sticker,
    required this.isNew,
    required this.ownedCount,
    required this.onClose,
    required this.onAgain,
  });

  final StickerData sticker;
  final bool isNew;
  final int ownedCount;
  final VoidCallback onClose;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final displayPath = sticker.iconPath.isNotEmpty ? sticker.iconPath : sticker.assetPath;
    final isGlb = displayPath.toLowerCase().endsWith('.glb');

    return Material(
      color: Colors.black26,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No.${sticker.number}  ${sticker.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              StickerTile(assetPath: displayPath, size: 160, useModelViewer: isGlb),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isNew ? const Color(0xFFFFE8D9) : const Color(0xFFE6FFFB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isNew ? 'New!' : 'もってるかず: $ownedCountまい',
                  style: TextStyle(
                    color: isNew ? const Color(0xFFB85B2A) : const Color(0xFF0F766E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(onPressed: onClose, child: const Text('とじる')),
                  ElevatedButton(
                    onPressed: onAgain,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6845A)),
                    child: const Text('もう一回'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
