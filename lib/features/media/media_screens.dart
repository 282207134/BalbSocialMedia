import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key, required this.kind});
  final String kind;
  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final comment = TextEditingController();
  bool liked = false, muted = false, camera = true, paused = false;
  int elapsed = 0;
  Timer? timer;
  final List<String> liveComments = [
    'Hello 👋',
    'I want to go there',
    'Wow, it’s beautiful 😍',
  ];
  @override
  void initState() {
    super.initState();
    if (widget.kind == 'call') {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => elapsed++);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final call = widget.kind == 'call',
        story = widget.kind == 'story',
        video = widget.kind == 'video';
    final s = StoreScope.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Photo(
            call
                ? 'call'
                : story
                ? 'story'
                : video
                ? 'video'
                : 'live',
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Colors.transparent,
                  Color(0x88000000),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
                  child: Column(
                    children: [
                      if (story) ...[
                        const LinearProgressIndicator(
                          value: .65,
                          minHeight: 2,
                          color: Colors.white,
                          backgroundColor: Colors.white30,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          if (video)
                            const Photo(
                              'logo',
                              width: 48,
                              height: 48,
                              radius: 4,
                            )
                          else
                            const Avatar(index: 0, size: 44),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              call
                                  ? 'Jesselin_'
                                  : story
                                  ? 'Alicestar'
                                  : video
                                  ? 'balb video'
                                  : 'Brittnil_',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (call)
                            Text(
                              'Preview · ${elapsed ~/ 60}:${(elapsed % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 10),
                            )
                          else if (!story && !video)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: BalbColors.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'LIVE PREVIEW',
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                          if (!call && !story && !video)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                '◉ 108',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (call)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 108,
                        height: 145,
                        child: camera
                            ? const Photo('call_self', radius: 12)
                            : Container(
                                color: BalbColors.surface,
                                child: const Icon(Icons.videocam_off_outlined),
                              ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (story)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        _storyLabel('Capturing memories,'),
                        const SizedBox(height: 8),
                        _storyLabel('one click at a time.'),
                        const SizedBox(height: 12),
                        const Text('📸', style: TextStyle(fontSize: 38)),
                      ],
                    ),
                  ),
                if (!call && !story && !video)
                  SizedBox(
                    height: 220,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        for (final t in liveComments)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Avatar(index: 2, size: 36),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Derrylo2',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        t,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                if (video)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Avatar(index: 0, size: 42),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Brittnil_',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  FollowButton(
                                    following: s.following.contains(
                                      'Brittnil_',
                                    ),
                                    onPressed: () =>
                                        s.toggle(s.following, 'Brittnil_'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Let’s groove to the beat of the 80s ✨',
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '♫ Depeche Mode · Video preview',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              tooltip: 'Like video',
                              onPressed: () => setState(() => liked = !liked),
                              icon: Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                color: liked
                                    ? BalbColors.secondary
                                    : Colors.white,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Comments',
                              onPressed: () => go(context, '/comments'),
                              icon: const Icon(Icons.chat_bubble_outline),
                            ),
                            IconButton(
                              tooltip: 'Pause preview',
                              onPressed: () => setState(() => paused = !paused),
                              icon: Icon(
                                paused ? Icons.play_arrow : Icons.pause,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (call)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _control(
                          camera
                              ? Icons.videocam_outlined
                              : Icons.videocam_off_outlined,
                          () => setState(() => camera = !camera),
                          'Toggle camera',
                        ),
                        _control(
                          muted ? Icons.mic_off : Icons.mic_none,
                          () => setState(() => muted = !muted),
                          'Toggle microphone',
                        ),
                        _control(
                          Icons.volume_up_outlined,
                          () => toast(
                            context,
                            'Call preview — no audio service is connected.',
                          ),
                          'Speaker',
                        ),
                        _control(
                          Icons.call_end,
                          () => Navigator.pop(context),
                          'End call',
                          red: true,
                        ),
                      ],
                    ),
                  )
                else if (!video)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 16, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: comment,
                            decoration: InputDecoration(
                              hintText: 'Add a comment',
                              fillColor: Colors.white.withValues(alpha: .15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => send(story),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Send comment',
                          onPressed: () => send(story),
                          icon: const Icon(Icons.send_outlined),
                        ),
                        IconButton(
                          tooltip: 'Like',
                          onPressed: () => setState(() => liked = !liked),
                          icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? BalbColors.secondary : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (video && paused)
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 76,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  void send(bool story) {
    if (comment.text.trim().isEmpty) return;
    if (story) {
      StoreScope.of(context).send(comment.text);
      toast(context, 'Reply saved to your conversation');
    } else {
      setState(() => liveComments.add(comment.text.trim()));
    }
    comment.clear();
    FocusScope.of(context).unfocus();
  }

  Widget _storyLabel(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    color: Colors.black54,
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
  Widget _control(
    IconData icon,
    VoidCallback action,
    String label, {
    bool red = false,
  }) => IconButton.filled(
    tooltip: label,
    style: IconButton.styleFrom(
      backgroundColor: red ? Colors.redAccent : Colors.black38,
      padding: const EdgeInsets.all(17),
    ),
    onPressed: action,
    icon: Icon(icon, color: Colors.white, size: 28),
  );
}
