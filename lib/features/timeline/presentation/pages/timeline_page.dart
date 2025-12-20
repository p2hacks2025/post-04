import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../nameplate/data/repositories/nameplate_storage.dart';
import '../../../nameplate/domain/constants/nameplate_constants.dart';
import '../../../nameplate/domain/models/models.dart';
import '../../../nameplate/presentation/widgets/nameplate_preview.dart';
import '../../data/repositories/public_board_repository.dart';
import '../widgets/sticker_board_snapshot_widget.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _repo = PublicBoardRepository();
  NameplateData? _myNameplate;

  @override
  void initState() {
    super.initState();
    _loadMyNameplate();
  }

  Future<void> _loadMyNameplate() async {
    final saved = await NameplateStorage.load();
    if (!mounted) return;
    setState(() => _myNameplate = saved);
  }

  NameplateData _fallbackNameplate() {
    return NameplateData(
      shape: NameplateShape.roundedSquare,
      backgroundColor: NameplateColors.backgroundColors[0],
      name: '',
      fontType: FontType.rounded,
      textColor: const Color(0xFFFF6FAE),
      hasOutline: true,
      hasShadow: true,
      decorations: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final myNp = _myNameplate ?? _fallbackNameplate();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('みんなの'),
        backgroundColor: const Color(0xFFC6845A),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyNameplate,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('あなたのネームプレート', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 160, child: NameplatePreview(data: myNp)),
            const SizedBox(height: 16),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: _repo.streamByUid(uid),
              builder: (context, snapshot) {
                final posts = snapshot.data ?? const [];
                return Column(
                  children: [
                    for (final p in posts) ...[
                      StickerBoardSnapshotWidget(snapshot: p.board),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
            const Divider(height: 32),
            const Text('タイムライン', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: _repo.streamAll(limit: 50),
              builder: (context, snapshot) {
                final posts = snapshot.data ?? const [];
                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('まだ公開がありません')),
                  );
                }

                return Column(
                  children: [
                    for (final p in posts) ...[
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 140, child: NameplatePreview(data: p.nameplate)),
                              const SizedBox(height: 10),
                              StickerBoardSnapshotWidget(snapshot: p.board),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  StreamBuilder<bool>(
                                    stream: _repo.streamIsLiked(p.id),
                                    builder: (context, likeSnap) {
                                      final liked = likeSnap.data ?? false;
                                      return IconButton(
                                        onPressed: () => _repo.toggleLike(p.id),
                                        icon: Icon(
                                          liked ? Icons.favorite : Icons.favorite_border,
                                          color: liked ? Colors.pink : Colors.black54,
                                        ),
                                        tooltip: liked ? 'いいね済み' : 'いいね',
                                      );
                                    },
                                  ),
                                  Text('${p.likeCount}'),
                                  const Spacer(),
                                  Text(
                                    'page ${p.page + 1}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
