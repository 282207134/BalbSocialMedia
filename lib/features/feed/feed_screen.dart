import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/post_draft.dart';
import '../../shared/post_photo.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, this.style = 0});
  final int style;
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int filter = 0;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          if (context.mounted) toast(context, 'You’re all caught up');
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 12, 22),
              child: Row(
                children: [
                  const Photo('logo', width: 48, height: 48, radius: 5),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => go(context, '/video'),
                    child: const Row(
                      children: [
                        Text(
                          'balb photo',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => go(context, '/notifications'),
                    icon: const Badge(
                      smallSize: 6,
                      child: Icon(Icons.notifications_none_outlined),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Feed options',
                    onSelected: (v) => go(context, v),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: '/home',
                        child: Text('Home V1'),
                      ),
                      const PopupMenuItem(
                        value: '/home-v2',
                        child: Text('Home V2 · Tabs'),
                      ),
                      const PopupMenuItem(
                        value: '/home-v3',
                        child: Text('Home V3 · Cards'),
                      ),
                      const PopupMenuItem(
                        value: '/video',
                        child: Text('Video feed'),
                      ),
                      const PopupMenuItem(
                        value: '/saved',
                        child: Text('Saved posts'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.style == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SegmentBar(
                  labels: const ['Following', 'Trending', 'Suggested'],
                  selected: filter,
                  onChanged: (v) => setState(() => filter = v),
                ),
              ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (c, i) => GestureDetector(
                  onTap: () => go(context, i < 3 ? '/live' : '/story'),
                  child: SizedBox(
                    width: 62,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Avatar(index: i, size: 60),
                            if (i < 3)
                              Positioned(
                                bottom: -1,
                                left: 9,
                                right: 9,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: BalbColors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'LIVE ●',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            'Brittnil_',
                            'Eleanorrr',
                            'Jackostill',
                            'Stepha77',
                            'Alicestar',
                            'Dann.Ger',
                          ][i],
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            for (final (i, p) in s.posts.indexed)
              PostCard(
                id: p['id'] ?? 'local_$i',
                draft: PostDraft.fromPost(p),
                author: s.username,
                caption: p['caption']!,
                images: [p['image']!],
                rounded: widget.style == 2,
                own: true,
              ),
            PostCard(
              id: filter == 1 ? 'sea' : 'alice',
              author: filter == 1 ? 'Eleanorrr' : 'Alicestar',
              caption: filter == 1
                  ? 'A little closer to the ocean.'
                  : 'Finding clarity in the shadows',
              images: filter == 1
                  ? const ['sea', 'feed', 'art']
                  : const ['feed', 'sea', 'art'],
              rounded: widget.style == 2,
            ),
            PostCard(
              id: 'art',
              author: 'Jackostill',
              caption: 'A world of color, one frame at a time.',
              images: filter == 2
                  ? const ['tech', 'art']
                  : const ['art', 'tech'],
              rounded: widget.style == 2,
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.id,
    required this.author,
    required this.caption,
    required this.images,
    this.rounded = false,
    this.own = false,
    this.draft,
  });
  final String id, author, caption;
  final List<String> images;
  final bool rounded, own;
  final PostDraft? draft;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 6,
          ),
          leading: Avatar(index: 4, asset: widget.own ? s.profileAvatar : null),
          title: Text(
            widget.author,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Photoholic',
            style: TextStyle(color: BalbColors.muted, fontSize: 13),
          ),
          onTap: () => go(context, widget.own ? '/profile' : '/user'),
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'save') {
                s.toggle(s.bookmarks, widget.id);
              } else {
                go(context, '/user');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'save',
                child: Text(
                  s.bookmarks.contains(widget.id)
                      ? 'Remove from saved'
                      : 'Save post',
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Text('View profile'),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.rounded ? 24 : 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.rounded ? 9 : 0),
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onDoubleTap: () {
                  if (!s.likes.contains(widget.id)) {
                    s.toggle(s.likes, widget.id);
                  }
                },
                child: PageView(
                  children: widget.images
                      .map(
                        (i) => widget.draft == null
                            ? Photo(i)
                            : DraftPhoto(widget.draft!, radius: 0),
                      )
                      .toList(),
                  onPageChanged: (v) => setState(() => page = v),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Like post',
                onPressed: () => s.toggle(s.likes, widget.id),
                icon: Icon(
                  s.likes.contains(widget.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: s.likes.contains(widget.id)
                      ? BalbColors.secondary
                      : Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Comments',
                onPressed: widget.draft?.comments == false
                    ? null
                    : () => go(context, '/comments'),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
              ),
              IconButton(
                tooltip: 'Save post',
                onPressed: () => s.toggle(s.bookmarks, widget.id),
                icon: Icon(
                  s.bookmarks.contains(widget.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  size: 23,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  widget.images.length,
                  (i) => Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page == i ? Colors.white : const Color(0xff4b5362),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 82,
                height: 25,
                child: Stack(
                  children: List.generate(
                    4,
                    (i) => Positioned(
                      left: i * 18,
                      child: Avatar(index: i, size: 25, ring: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(widget.caption, style: const TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
          child: Text(
            s.likes.contains(widget.id)
                ? 'You and 815 others liked this · 20m ago'
                : '20m ago',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}
