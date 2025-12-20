import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/services/gacha_limit_store.dart';
import '../../../sticker_book/data/sticker_master.dart';
import '../../../sticker_book/data/services/sticker_count_store.dart';
import '../../../sticker_book/presentation/widgets/sticker_tile.dart';

class GachaPage extends StatefulWidget {
  const GachaPage({super.key, this.rarityWeights, this.dailyLimit = 5});

  // レア度→重み（大きいほど出やすい）。未指定ならデフォルト
  final Map<int, double>? rarityWeights;

  // 1日に引ける回数（未指定なら 5 回）
  final int dailyLimit;

  @override
  State<GachaPage> createState() => _GachaPageState();
}

enum _GachaPhase { idle, animating, result }

class _GachaPageState extends State<GachaPage> with SingleTickerProviderStateMixin {
  final _rand = Random();
  late final StickerCountStore _countStore;
  late final GachaLimitStore _limitStore;
  late final List<StickerData> _catalog;
  late final Map<int, double> _weights = widget.rarityWeights ?? {
    1: 50, 2: 30, 3: 15, 4: 4, 5: 1,
  };

  _GachaPhase _phase = _GachaPhase.idle;
  StickerData? _result;
  bool _isNew = false;
  int _remainingToday = 0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400), // 2.4秒のタメ
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) _revealResult();
    });

  @override
  void initState() {
    super.initState();
    _catalog = List.of(stickerMasterData)..sort((a, b) => a.number.compareTo(b.number));
    _countStore = StickerCountStore(_catalog.map((e) => e.assetPath).toList());
    _limitStore = GachaLimitStore(dailyLimit: widget.dailyLimit);
    _init();
  }

  Future<void> _init() async {
    await _countStore.loadOrInit();
    await _limitStore.loadOrInit();
    setState(() {
      _remainingToday = _limitStore.remaining;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startGacha() async {
    if (_phase == _GachaPhase.animating) return;

    if (_remainingToday <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('今日はもうガチャを引けないよ…')),
      );
      return;
    }

    try {
      final ok = await _limitStore.consumeOne();
      if (!ok) {
        if (!mounted) return;
        setState(() {
          _remainingToday = _limitStore.remaining;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('今日はもうガチャを引けないよ…')),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _remainingToday = _limitStore.remaining;
        _phase = _GachaPhase.animating;
        _result = null;
      });
      _controller.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しちゃった…もう一回ためしてね')),
      );
    }
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
    final canStart = !isAnimating && _remainingToday > 0;

    // かわいい箱の演出（ゆらゆら＋ぷにっと拡縮＋キラキラ）

    return Scaffold(
      appBar: AppBar(title: const Text('ガチャ')),
      backgroundColor: AppColors.background,
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
                          colors: [
                            AppColors.gachaBoxGradientStart,
                            AppColors.gachaBoxGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gachaGlow.withValues(alpha: glowAlpha),
                            blurRadius: 30 * glowAlpha,
                            spreadRadius: 6 * glowAlpha,
                          ),
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.card_giftcard, size: 64, color: AppColors.primaryDark),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '今日あと $_remainingToday 回',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: _remainingToday > 0 ? AppColors.primaryDark : AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: canStart ? () => _startGacha() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                child: Text(isAnimating ? '抽選中...' : 'ガチャをひく'),
              ),
            ],
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
    // ガチャ結果はマスタの本体（assetPath）を表示する
    final displayPath = sticker.assetPath;
    final isGlb = displayPath.toLowerCase().endsWith('.glb');

    return Material(
      color: AppColors.shadowDark,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppColors.shadowDark, blurRadius: 20, spreadRadius: 4),
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
                  color: isNew ? AppColors.primaryLight : AppColors.successLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isNew ? 'New!' : 'もってるかず: $ownedCountまい',
                  style: TextStyle(
                    color: isNew ? AppColors.primaryDark : AppColors.success,
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
