import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';

const topicNames = [
  'Sports',
  'Entertainment',
  'Music',
  'Technology',
  'Fashion & Beauty',
  'Travel',
  'Art & Culture',
  'Gaming',
];

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      children: [
        GestureDetector(
          onTap: () => go(context, '/search'),
          child: const AbsorbPointer(
            child: Field('Search', icon: Icons.search),
          ),
        ),
        Heading(
          'Topics',
          action: 'See all',
          onTap: () => go(context, '/topics'),
        ),
        const TopicGrid(),
        const Heading('For you'),
        const DiscoveryPhotos(),
      ],
    ),
  );
}

class TopicGrid extends StatelessWidget {
  const TopicGrid({super.key});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
    ),
    itemCount: 8,
    itemBuilder: (c, i) => GestureDetector(
      onTap: () => go(context, '/topic', arguments: topicNames[i]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                [const Color(0xff93e3de), const Color(0xff4d86ed)],
                [const Color(0xffff7b7b), const Color(0xffcd1313)],
                [const Color(0xffffc615), const Color(0xffff8a00)],
                [const Color(0xff53e4f2), const Color(0xff4647ff)],
                [const Color(0xffffc5e6), const Color(0xfff99ee2)],
                [const Color(0xffd6f4f5), const Color(0xff8bc8d5)],
                [const Color(0xffe492f9), const Color(0xff7616c8)],
                [const Color(0xff1fe277), const Color(0xff007c4e)],
              ][i],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -12,
                bottom: -14,
                width: 85,
                height: 85,
                child: Photo('topic_$i', fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.all(7),
                child: Text(
                  topicNames[i],
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class DiscoveryPhotos extends StatelessWidget {
  const DiscoveryPhotos({super.key});
  Widget tile(BuildContext context, String name, double ratio) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: GestureDetector(
      onTap: () => go(context, '/post-detail', arguments: name),
      child: AspectRatio(aspectRatio: ratio, child: Photo(name, radius: 8)),
    ),
  );
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          children: [
            tile(context, 'art', 1),
            tile(context, 'tech', 1),
            tile(context, 'feed', .8),
          ],
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          children: [
            tile(context, 'sea', 1.54),
            tile(context, 'concert', .74),
            tile(context, 'food_0', 1),
          ],
        ),
      ),
    ],
  );
}

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key, this.topic});
  final String? topic;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: topic ?? 'Topics',
    child: Column(
      children: [
        const TopicGrid(),
        const SizedBox(height: 20),
        if (topic != null) const DiscoveryPhotos(),
      ],
    ),
  );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final query = TextEditingController(text: 'Aura');
  int tab = 0;
  static const people = [
    ('Aurani_88', 'Makeup Artist', 0),
    ('auradome', 'Pro Gamers', 1),
    ('Aurasilly_', 'Beauty Enthusiast', 4),
    ('Alicestar', 'Photoholic', 4),
    ('madelinechrista', 'Make Up Artist', 3),
    ('Jesselin_', 'Music Enthusiast', 1),
  ];
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final q = query.text.trim().toLowerCase();
    final results = people
        .where((p) => '${p.$1} ${p.$2}'.toLowerCase().contains(q))
        .toList();
    return PageFrame(
      title: 'Search',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: query,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search accounts or posts',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  query.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.cancel_outlined, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SegmentBar(
            labels: const ['All', 'Account', 'Post'],
            selected: tab,
            onChanged: (v) => setState(() => tab = v),
          ),
          if (tab != 2) ...[
            const Heading('Account'),
            if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No accounts found. Try “Alice” or “Aura”.',
                  style: TextStyle(color: BalbColors.muted),
                ),
              ),
            for (final p in results)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  tileColor: BalbColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: Avatar(index: p.$3, size: 60),
                  title: Text(
                    p.$1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${p.$2}\n${p.$3 + 2} mutual friends',
                    style: const TextStyle(
                      fontSize: 11,
                      color: BalbColors.muted,
                    ),
                  ),
                  trailing: FollowButton(
                    following: s.following.contains(p.$1),
                    onPressed: () => s.toggle(s.following, p.$1),
                  ),
                  onTap: () => go(context, '/user'),
                ),
              ),
          ],
          if (tab != 1) ...[
            const Heading('Post'),
            if (q.isEmpty ||
                [
                  'aura',
                  'art',
                  'music',
                  'travel',
                  'photo',
                  'sea',
                ].any((t) => q.contains(t)))
              const DiscoveryPhotos()
            else
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No posts found for this search.',
                  style: TextStyle(color: BalbColors.muted),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
