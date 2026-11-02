import 'dart:math' as math;

import '../../core/post_draft.dart';

import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../../shared/post_photo.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int mode = 0;
  bool flash = false, flip = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(flip ? math.pi : 0),
                  child: const Photo('post'),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Close camera',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel_outlined),
                      ),
                      IconButton(
                        tooltip: 'Flash',
                        onPressed: () => setState(() => flash = !flash),
                        icon: Icon(flash ? Icons.flash_on : Icons.flash_off),
                      ),
                      IconButton(
                        tooltip: 'Camera information',
                        onPressed: () => toast(
                          context,
                          'Camera preview uses the photo supplied in Pixso. Tap the shutter or choose a gallery image.',
                        ),
                        icon: const Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 24,
                  right: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => go(context, '/gallery'),
                        child: const Photo(
                          'art',
                          width: 48,
                          height: 48,
                          radius: 4,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Capture photo',
                        child: GestureDetector(
                          onTap: () {
                            final s = StoreScope.of(context);
                            s.draft = PostDraft();
                            go(context, mode == 3 ? '/live' : '/filter');
                          },
                          child: Container(
                            width: 68,
                            height: 68,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: mode == 2
                                    ? BalbColors.secondary
                                    : Colors.white.withValues(alpha: .75),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Flip camera',
                        onPressed: () => setState(() => flip = !flip),
                        icon: const Icon(Icons.cameraswitch_outlined, size: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SegmentBar(
              labels: const ['Post', 'Story', 'Video', 'Live'],
              selected: mode,
              onChanged: (v) => setState(() => mode = v),
            ),
          ),
        ],
      ),
    ),
  );
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static final images = [
    'art',
    'sea',
    'food_3',
    'tech',
    'beauty_0',
    'food_0',
    'post',
    'concert',
    'story',
    'food_7',
    'beauty_4',
    'live',
    'food_2',
    'food_8',
    'beauty_9',
    'feed',
  ];
  int selected = 0;
  bool multiple = false;
  final selections = <int>{0};
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'New Post',
    actions: [
      TextButton(
        onPressed: () {
          final s = StoreScope.of(context);
          s.draft = PostDraft()..image = images[selected];
          go(context, '/filter');
        },
        child: const Text('Next'),
      ),
    ],
    child: Column(
      children: [
        AspectRatio(aspectRatio: 1, child: Photo(images[selected], radius: 5)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Gallery ▾'),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => multiple = !multiple),
              icon: Icon(
                multiple ? Icons.check_circle : Icons.layers_outlined,
                size: 16,
              ),
              label: const Text('Multiple', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (c, i) => GestureDetector(
            onTap: () => setState(() {
              selected = i;
              if (multiple) {
                selections.contains(i)
                    ? selections.remove(i)
                    : selections.add(i);
              }
            }),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Photo(images[i]),
                if (i == selected || multiple && selections.contains(i))
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: BalbColors.primary, width: 3),
                    ),
                    alignment: Alignment.topRight,
                    child: const Icon(
                      Icons.check_circle,
                      color: BalbColors.primary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (multiple)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'The highlighted preview is used for this demo post.',
              style: TextStyle(fontSize: 11, color: BalbColors.muted),
            ),
          ),
      ],
    ),
  );
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, this.edit = false});
  final bool edit;
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int tool = 1;
  @override
  Widget build(BuildContext context) {
    final d = StoreScope.of(context).draft;
    return PageFrame(
      title: 'New Post',
      actions: [
        TextButton(
          onPressed: () => go(context, '/share'),
          child: const Text('Next'),
        ),
      ],
      bottom: SegmentBar(
        labels: const ['Filter', 'Edit'],
        selected: widget.edit ? 1 : 0,
        onChanged: (v) {
          if (v != (widget.edit ? 1 : 0)) {
            Navigator.pushReplacementNamed(
              context,
              v == 0 ? '/filter' : '/edit',
            );
          }
        },
      ),
      child: Column(
        children: [
          AspectRatio(aspectRatio: .76, child: DraftPhoto(d)),
          const SizedBox(height: 24),
          if (!widget.edit)
            SizedBox(
              height: 134,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (c, i) => GestureDetector(
                  onTap: () => setState(() => d.filter = i),
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: d.filter == i
                                    ? BalbColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(
                                (PostDraft()
                                      ..image = d.image
                                      ..filter = i)
                                    .matrix,
                              ),
                              child: Photo(d.image, radius: 3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          ['DEFAULT', 'JAPAN', 'INDONESIA', 'SAUDI'][i],
                          style: TextStyle(
                            fontSize: 10,
                            color: d.filter == i
                                ? Colors.white
                                : BalbColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else ...[
            if (tool > 0)
              Slider(
                value: tool == 1
                    ? d.brightness
                    : tool == 2
                    ? d.contrast
                    : d.saturation,
                min: tool == 1 ? -1 : 0,
                max: tool == 1 ? 1 : 2,
                onChanged: (v) => setState(() {
                  if (tool == 1) {
                    d.brightness = v;
                  } else if (tool == 2) {
                    d.contrast = v;
                  } else {
                    d.saturation = v;
                  }
                }),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (i) => Column(
                  children: [
                    IconButton(
                      tooltip: [
                        'Rotate photo',
                        'Brightness',
                        'Contrast',
                        'Saturation',
                      ][i],
                      onPressed: () => setState(() {
                        tool = i;
                        if (i == 0) d.rotation = (d.rotation + 1) % 4;
                      }),
                      icon: Icon(
                        [
                          Icons.crop_rotate,
                          Icons.brightness_6_outlined,
                          Icons.contrast,
                          Icons.color_lens_outlined,
                        ][i],
                        color: tool == i
                            ? BalbColors.primary
                            : BalbColors.muted,
                      ),
                    ),
                    Text(
                      ['ROTATE', 'BRIGHTNESS', 'CONTRAST', 'SATURATION'][i],
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});
  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final caption = TextEditingController();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      caption.text = StoreScope.of(context).draft.caption;
      initialized = true;
    }
  }

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  Future<void> editValue(
    String title,
    String value,
    ValueChanged<String> save,
  ) async {
    final controller = TextEditingController(text: value);
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => save(result));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context), d = s.draft;
    return PageFrame(
      title: 'New Post',
      actions: [
        TextButton(
          onPressed: () {
            d.caption = caption.text;
            toast(context, 'Draft saved for this session');
          },
          child: const Text('Save'),
        ),
      ],
      bottom: PrimaryButton(
        'Share',
        onPressed: () {
          d.caption = caption.text;
          s.publishDraft();
          home(context);
        },
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 110, height: 115, child: DraftPhoto(d)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: caption,
                  maxLines: 4,
                  onChanged: (v) => d.caption = v,
                  decoration: const InputDecoration(
                    hintText: 'Write a caption...',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _row(
            'Tag people',
            d.tag,
            () => editValue('Tag people', d.tag, (v) => d.tag = v),
          ),
          _row(
            'Add location',
            d.location,
            () => editValue('Add location', d.location, (v) => d.location = v),
          ),
          _row(
            'Add music',
            d.music,
            () => editValue('Add music', d.music, (v) => d.music = v),
          ),
          _switch('Allow comment', d.comments, (v) => d.comments = v),
          const Heading('Post to other social media account'),
          _switch('Facebook', d.facebook, (v) {
            d.facebook = v;
            if (v) {
              toast(
                context,
                'Facebook sharing requires a connected account. This post will be saved locally.',
              );
            }
          }),
          _switch('Twitter', d.twitter, (v) {
            d.twitter = v;
            if (v) {
              toast(
                context,
                'Twitter sharing requires a connected account. This post will be saved locally.',
              );
            }
          }),
          _row(
            'Advance settings',
            '',
            () => showModalBottomSheet<void>(
              context: context,
              builder: (c) => const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Posts are stored on this device. Location, tags and music names are saved as text. Connect a publishing service to share them online.',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: ListTile(
      tileColor: const Color(0xff303b3a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: value.isEmpty ? null : Text(value),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    ),
  );
  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SwitchListTile(
          tileColor: const Color(0xff303b3a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          value: value,
          onChanged: (v) => setState(() => onChanged(v)),
        ),
      );
}
