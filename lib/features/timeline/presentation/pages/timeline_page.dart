import 'package:flutter/material.dart';

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

  Future<void> _refresh() async {
    // Timeline is driven by StreamBuilder; keep pull-to-refresh UX.
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'みんなのシール帳',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFFC6845A),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                    for (var i = 0; i < posts.length; i++) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 140,
                            child: NameplatePreview(data: posts[i].nameplate),
                          ),
                          const SizedBox(height: 10),
                          StickerBoardSnapshotWidget(snapshot: posts[i].board),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              StreamBuilder<bool>(
                                stream: _repo.streamIsLiked(posts[i].id),
                                builder: (context, likeSnap) {
                                  final liked = likeSnap.data ?? false;
                                  return TextButton.icon(
                                    onPressed: () => _repo.toggleLike(posts[i].id),
                                    icon: Icon(
                                      liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: liked
                                          ? Colors.pink
                                          : Colors.black54,
                                      size: 20,
                                    ),
                                    label: const Text('すてきだね'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              Text('${posts[i].likeCount}'),
                              const Spacer(),
                              Text(
                                'page ${posts[i].page + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (i < posts.length - 1) ...[
                        const SizedBox(height: 24),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.withValues(alpha: 0.2),
                          indent: 16,
                          endIndent: 16,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
