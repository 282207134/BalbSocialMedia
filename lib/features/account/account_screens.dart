import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/post_draft.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../feed/feed_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.other = false});
  final bool other;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final other = widget.other;
    return ListView(
      padding: EdgeInsets.only(bottom: other ? 24 : 120),
      children: [
        SizedBox(
          height: 325,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 275,
                child: Photo(other ? 'user_cover' : s.profileCover),
              ),
              if (other)
                Positioned(
                  top: 12,
                  left: 12,
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              Positioned(
                left: 24,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: BalbColors.background, width: 4),
                  ),
                  child: Avatar(
                    asset: other ? 'user_avatar' : s.profileAvatar,
                    size: 120,
                    ring: false,
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 0,
                child: Row(
                  children: other
                      ? [
                          FollowButton(
                            following: s.following.contains('madelinechrista'),
                            onPressed: () =>
                                s.toggle(s.following, 'madelinechrista'),
                          ),
                          const SizedBox(width: 8),
                          _circle(
                            Icons.mail_outline,
                            () => go(context, '/chat'),
                          ),
                        ]
                      : [
                          _circle(
                            Icons.notifications_none_outlined,
                            () => go(context, '/notifications'),
                          ),
                          _circle(
                            Icons.filter_alt_outlined,
                            () => go(context, '/saved'),
                          ),
                          _circle(
                            Icons.edit_outlined,
                            () => go(context, '/edit-profile'),
                          ),
                          _circle(
                            Icons.settings_outlined,
                            () => go(context, '/settings'),
                          ),
                        ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                other ? 'madelinechrista' : s.username,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                other ? 'Make Up Artist' : s.bio,
                style: const TextStyle(color: BalbColors.muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  _stat(other ? '90' : '${21 + s.posts.length}', 'Post'),
                  _stat(other ? '2k' : '815', 'Followers'),
                  _stat(
                    '${(other ? 81 : 120) + s.following.length}',
                    'Following',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SegmentBar(
                labels: const ['Photos', 'Videos', 'Tagged'],
                selected: tab,
                onChanged: (v) => setState(() => tab = v),
              ),
              const SizedBox(height: 24),
              if (tab == 0)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 16 + (other ? 0 : s.posts.length),
                  itemBuilder: (c, i) {
                    final image = !other && i < s.posts.length
                        ? s.posts[i]['image']!
                        : '${other ? 'beauty' : 'food'}_${(i - (other ? 0 : s.posts.length)) % 16}';
                    return GestureDetector(
                      onTap: () =>
                          go(context, '/post-detail', arguments: image),
                      child: Photo(image, radius: 3),
                    );
                  },
                ),
              if (tab == 1)
                GestureDetector(
                  onTap: () => go(context, '/video'),
                  child: const AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Photo('video', radius: 8),
                        Center(
                          child: Icon(Icons.play_circle_outline, size: 58),
                        ),
                      ],
                    ),
                  ),
                ),
              if (tab == 2)
                const Column(
                  children: [
                    SizedBox(height: 40),
                    Icon(
                      Icons.person_pin_outlined,
                      size: 50,
                      color: BalbColors.muted,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Photos you’re tagged in will appear here.',
                      style: TextStyle(color: BalbColors.muted),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circle(IconData icon, VoidCallback action) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xff303333),
        minimumSize: const Size(40, 40),
        maximumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
      ),
      tooltip: switch (icon) {
        Icons.settings_outlined => 'Settings',
        Icons.edit_outlined => 'Edit profile',
        Icons.notifications_none_outlined => 'Notifications',
        _ => 'Saved posts',
      },
      onPressed: action,
      icon: Icon(icon, size: 23),
    ),
  );
  Widget _stat(String number, String label) => Padding(
    padding: const EdgeInsets.only(right: 14),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$number ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(fontSize: 10, color: BalbColors.muted),
          ),
        ],
      ),
    ),
  );
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: SafeArea(child: ProfileScreen(other: true)));
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: 'Saved posts',
      padding: EdgeInsets.zero,
      child: Column(
        children: s.bookmarks.isEmpty
            ? const [
                SizedBox(height: 120),
                Icon(Icons.bookmark_outline, size: 56, color: BalbColors.muted),
                SizedBox(height: 20),
                Text('Save the moments you want to keep.'),
              ]
            : s.bookmarks.map((id) {
                final index = id.startsWith('local_')
                    ? int.tryParse(id.substring(6))
                    : null;
                final matches = s.posts.where((p) => p['id'] == id);
                final p = matches.isNotEmpty
                    ? matches.first
                    : index != null && index < s.posts.length
                    ? s.posts[index]
                    : null;
                return PostCard(
                  id: id,
                  draft: p == null ? null : PostDraft.fromPost(p),
                  author: p == null ? 'Alicestar' : s.username,
                  caption: p?['caption'] ?? 'Finding clarity in the shadows',
                  images: [p?['image'] ?? (id == 'art' ? 'art' : 'feed')],
                );
              }).toList(),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Settings',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in {
          'Account': [
            (Icons.account_circle_outlined, 'Account'),
            (Icons.lock_outline, 'Privacy'),
          ],
          'General': [
            (Icons.notifications_none, 'Notification'),
            (Icons.verified_user_outlined, 'Security'),
            (Icons.translate, 'Language'),
          ],
          'About': [
            (Icons.support_agent, 'Help'),
            (Icons.info_outline, 'About Us'),
          ],
        }.entries) ...[
          Heading(group.key),
          Material(
            color: BalbColors.surface,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                for (final (i, item) in group.value.indexed) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1),
                    ),
                  ListTile(
                    leading: Icon(item.$1, size: 23),
                    title: Text(item.$2, style: const TextStyle(fontSize: 13)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => item.$2 == 'Account'
                        ? go(context, '/edit-profile')
                        : go(context, '/setting-detail', arguments: item.$2),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 30),
        ListTile(
          tileColor: const Color(0xff2c2020),
          leading: const Icon(Icons.logout, color: BalbColors.secondary),
          title: const Text(
            'Log out',
            style: TextStyle(color: BalbColors.secondary),
          ),
          onTap: () async {
            final approved = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Log out?'),
                content: const Text(
                  'Your local posts and profile will stay on this device.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Log out'),
                  ),
                ],
              ),
            );
            if (approved == true && context.mounted) {
              final s = StoreScope.of(context);
              s.signedIn = false;
              await s.save();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/sign-in',
                  (_) => false,
                );
              }
            }
          },
        ),
      ],
    ),
  );
}

class SettingDetailScreen extends StatelessWidget {
  const SettingDetailScreen({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: title,
      child: switch (title) {
        'Notification' => SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Local preference for future notifications'),
          value: s.settings['Notifications']!,
          onChanged: (v) {
            s.settings['Notifications'] = v;
            s.save();
          },
        ),
        'Privacy' => SwitchListTile(
          title: const Text('Private account'),
          subtitle: const Text('Local demo preference'),
          value: s.settings['Private account']!,
          onChanged: (v) {
            s.settings['Private account'] = v;
            s.save();
          },
        ),
        'Security' => Column(
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: BalbColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'This demonstration stores no passwords. Authentication and account security require a connected service.',
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              'Change Password',
              onPressed: () => go(context, '/recovery'),
            ),
          ],
        ),
        'Language' => const ListTile(
          title: Text('English'),
          trailing: Icon(Icons.check, color: BalbColors.primary),
          subtitle: Text('Matches the original Pixso design'),
        ),
        'Help' => const Text(
          'Explore the feed, discover topics, follow creators and create a post from the + button.\n\nDemo verification code: 1234.\n\nAll activity is stored locally on this device. Social sign-in, contact imports, live streaming and video calling need external services.',
        ),
        _ => const Column(
          children: [
            Photo('logo', width: 100, height: 100),
            SizedBox(height: 24),
            Text('balb', style: TextStyle(fontFamily: 'Poppins', fontSize: 32)),
            SizedBox(height: 8),
            Text(
              'Share your passion.\nConnect with like-minded people.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'Version 1.0.0 · Flutter\nBased on Balb — Social Media App UI Kit',
              textAlign: TextAlign.center,
              style: TextStyle(color: BalbColors.muted),
            ),
          ],
        ),
      },
    );
  }
}
