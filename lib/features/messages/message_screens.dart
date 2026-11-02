import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  static const names = [
    'Jesselin_',
    'betatechsavvy',
    'jasonstar_23',
    'vitalykutuzov_1',
    'helenaarm',
    'gregoriany',
  ];
  static const previews = [
    'Coachella typically takes place over two weekends in April, with the exact dates varying from year to year.',
    'NFT stands for Non-Fungible Token, a unique digital asset.',
    'Offer your skills and services, such as writing, graphic design, or programming.',
    'A UI Designer creates the interfaces of digital products.',
    'Becoming a successful creator takes creativity and hard work.',
    'Let’s explore something new together.',
  ];
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  'Message',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Search people',
                onPressed: () => go(context, '/search'),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const Heading('Frequent Contacts'),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (c, i) => GestureDetector(
                onTap: () => go(context, '/chat', arguments: names[i]),
                child: Column(
                  children: [
                    Avatar(index: i, size: 60),
                    const SizedBox(height: 6),
                    Text(
                      [
                        'danjason',
                        'thegreat_v',
                        'sistar22',
                        'mcmanaman',
                        'official_ger',
                        'stevenpon1',
                      ][i],
                      style: const TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Heading('Recent Conversations'),
          for (final (i, n) in names.indexed) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              leading: Avatar(index: i == 0 ? 1 : i, size: 48),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      n,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    i < 2 ? '22.10' : '${i - 1} d ago',
                    style: const TextStyle(
                      fontSize: 10,
                      color: BalbColors.muted,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                i == 0 && s.messages.isNotEmpty ? s.messages.last : previews[i],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: BalbColors.muted),
              ),
              trailing: i < 2 ? const Badge(label: Text('1')) : null,
              onTap: () => go(context, '/chat', arguments: n),
            ),
            const Divider(height: 8),
          ],
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.name = 'Jesselin_'});
  final String name;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final text = TextEditingController();
  final scroll = ScrollController();
  bool audio = false;
  @override
  void dispose() {
    text.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    if (text.text.trim().isEmpty) return;
    final s = StoreScope.of(context);
    s.send(text.text, thread: widget.name);
    text.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final messages = widget.name == 'Jesselin_'
        ? s.messages
        : s.threads[widget.name] ?? <String>[];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Avatar(index: 1, size: 42),
            const SizedBox(width: 10),
            Text(widget.name, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Video call preview',
            onPressed: () => go(context, '/call'),
            icon: const Icon(Icons.videocam_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (_) => go(context, '/user'),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('View profile'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Today', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  if (widget.name == 'Jesselin_') ...[
                    _bubble('Hey Jesselin, what is Coachella?', true, '22.10'),
                    _bubble(
                      'Coachella is one of the largest and most famous music festivals in the world.',
                      false,
                      '22.10',
                      image: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 245,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => audio = !audio),
                              child: Icon(
                                audio
                                    ? Icons.pause_circle
                                    : Icons.play_circle_fill,
                                color: BalbColors.secondary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: LinearProgressIndicator(
                                value: .35,
                                color: BalbColors.primary,
                                backgroundColor: Color(0xffb7b7b7),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              audio ? 'Preview' : '00:49 / 49:00',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _bubble('Ok, My Pleasure\n😊', false, '22.13'),
                  ],
                  for (final m in messages) _bubble(m, true, 'Now'),
                  if (widget.name != 'Jesselin_' && messages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Text(
                        'Start a conversation. Say hello!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: BalbColors.muted),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: text,
                      onSubmitted: (_) => send(),
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Attach photo',
                    onPressed: () => go(context, '/gallery'),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                  IconButton(
                    tooltip: 'Send message',
                    onPressed: send,
                    icon: const Icon(
                      Icons.send_outlined,
                      color: BalbColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(String message, bool own, String time, {bool image = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: own
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Align(
              alignment: own ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 268),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: own ? BalbColors.primary : BalbColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(own ? 14 : 2),
                    bottomRight: Radius.circular(own ? 2 : 14),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ),
            if (image)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Photo('chat_poster', width: 184, height: 184),
              ),
            const SizedBox(height: 5),
            Text(
              '$time${own ? ' ✓✓' : ''}',
              style: const TextStyle(fontSize: 10, color: BalbColors.muted),
            ),
          ],
        ),
      );
}

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});
  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final text = TextEditingController();
  final liked = <int>{};
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final comments = [
      'Stunning silhouette capture! The play of light and shadow adds depth and drama to the image, making it truly captivating.',
      'It’s amazing Alice!',
      'Always top! ✨',
      ...s.comments,
    ];
    return PageFrame(
      title: 'Comments',
      bottom: Row(
        children: [
          Expanded(
            child: TextField(
              controller: text,
              decoration: const InputDecoration(hintText: 'Add a comment'),
            ),
          ),
          TextButton(
            onPressed: () {
              s.comment(text.text);
              text.clear();
              FocusScope.of(context).unfocus();
            },
            child: const Text('Post'),
          ),
        ],
      ),
      child: Column(
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(index: 4),
            title: Text('Alicestar'),
            subtitle: Text('Finding clarity in the shadows'),
          ),
          const Divider(),
          for (final (i, c) in comments.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(
                    index: i,
                    size: 40,
                    asset: i >= 3 ? 'profile_avatar' : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i >= 3
                              ? s.username
                              : ['Jaxxie', 'Diavandadome', 'Shellyana11'][i],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c,
                          style: const TextStyle(
                            fontSize: 12,
                            color: BalbColors.muted,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => setState(
                                () => liked.contains(i)
                                    ? liked.remove(i)
                                    : liked.add(i),
                              ),
                              icon: Icon(
                                liked.contains(i)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 15,
                                color: liked.contains(i)
                                    ? BalbColors.secondary
                                    : BalbColors.muted,
                              ),
                              label: Text(
                                liked.contains(i) ? 'Liked' : 'Like',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                text.text =
                                    '@${i >= 3 ? s.username : ['Jaxxie', 'Diavandadome', 'Shellyana11'][i]} ';
                              },
                              child: const Text(
                                'Reply',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: 'Notification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (g, items) in {
            'Today': ['thestrongstone', 'silvanevana'],
            'Yesterday': ['parkchool', 'geraldineshane', 'joshmaguire21'],
            'This Week': ['nicoleegab', 'michael_edward'],
          }.entries.map((e) => (e.key, e.value))) ...[
            Heading(g),
            for (final (i, n) in items.indexed)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: Avatar(index: i, size: 48),
                title: Text(
                  n,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  i == 0
                      ? 'Started Following you · 1h ago'
                      : 'Liked your post · 1d ago',
                  style: const TextStyle(fontSize: 10, color: BalbColors.muted),
                ),
                trailing: g == 'Today'
                    ? FollowButton(
                        following: s.following.contains(n),
                        onPressed: () => s.toggle(s.following, n),
                      )
                    : const Photo('post', width: 34, height: 45, radius: 3),
                onTap: () => go(context, '/user'),
              ),
          ],
        ],
      ),
    );
  }
}
