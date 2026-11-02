import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.setup = false});
  final bool setup;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      username = TextEditingController(),
      email = TextEditingController(),
      birthday = TextEditingController(),
      bio = TextEditingController();
  bool initialized = false;
  String? selectedCover, selectedAvatar;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final s = StoreScope.of(context);
      name.text = s.name;
      username.text = s.username;
      email.text = s.email;
      birthday.text = s.birthday;
      bio.text = s.bio;
      if (!widget.setup) {
        selectedCover = s.profileCover;
        selectedAvatar = s.profileAvatar;
      }
      initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in [name, username, email, birthday, bio]) {
      c.dispose();
    }
    super.dispose();
  }

  void save() {
    if (!form.currentState!.validate()) return;
    final s = StoreScope.of(context);
    s.name = name.text.trim();
    s.username = username.text.trim();
    s.email = email.text.trim();
    s.bio = bio.text.trim();
    s.birthday = birthday.text;
    s.profileCover = selectedCover ?? s.profileCover;
    s.profileAvatar = selectedAvatar ?? s.profileAvatar;
    s.save();
    if (widget.setup) {
      go(context, '/interests');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Account Setup',
    padding: EdgeInsets.zero,
    bottom: Row(
      children: [
        if (widget.setup) ...[
          Expanded(
            child: TextButton(
              onPressed: () => go(context, '/interests'),
              child: const Text('Skip', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(child: PrimaryButton('Save', onPressed: save)),
      ],
    ),
    child: Form(
      key: form,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(
                    () => selectedCover = selectedCover == 'sea'
                        ? 'profile_cover'
                        : 'sea',
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff24aeb4), Color(0xff78d8d2)],
                      ),
                    ),
                    child: selectedCover != null
                        ? Photo(selectedCover!)
                        : const Center(
                            child: Icon(Icons.camera_alt_outlined, size: 28),
                          ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => setState(
                      () => selectedAvatar = selectedAvatar == 'avatar_2'
                          ? 'profile_avatar'
                          : 'avatar_2',
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: BalbColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: BalbColors.background,
                          width: 4,
                        ),
                      ),
                      child: selectedAvatar != null
                          ? Avatar(
                              asset: selectedAvatar!,
                              size: 112,
                              ring: false,
                            )
                          : const Icon(Icons.add_a_photo_outlined, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Field(
                  'Full Name',
                  icon: Icons.person_outline,
                  controller: name,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                Field(
                  'Username',
                  icon: Icons.badge_outlined,
                  controller: username,
                  validator: (v) =>
                      RegExp(r'^[a-zA-Z0-9_]{3,24}$').hasMatch(v ?? '')
                      ? null
                      : 'Use 3–24 letters, numbers or underscores',
                ),
                Field(
                  'Email',
                  icon: Icons.mail_outline,
                  controller: email,
                  validator: (v) =>
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
                      ? null
                      : 'Enter a valid email',
                ),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      birthday.text = '${date.month}/${date.day}/${date.year}';
                    }
                  },
                  child: AbsorbPointer(
                    child: Field(
                      'MM/DD/YYYY',
                      icon: Icons.calendar_today_outlined,
                      controller: birthday,
                    ),
                  ),
                ),
                Field(
                  'Bio',
                  icon: Icons.notes_rounded,
                  controller: bio,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});
  static const groups = {
    'Sport': [
      'soccer',
      'badminton',
      'futsal',
      'basketball',
      'tennis',
      'baseball',
      'climbing',
      'volley ball',
      'swimming',
    ],
    'Entertainment': [
      'mr beast',
      'anime',
      'digital creators',
      'Marvel universe',
      'dc',
      'hollywood',
      'movie',
      'kaiju',
      'screen writing',
    ],
    'Music': [
      'bts',
      'grammy awards',
      'coachella',
      'record store day',
      'iHeart',
      'kpop',
      'city pop',
      'bonnaroo',
      'lollapalooza',
    ],
  };
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: 'Account Setup',
      bottom: PrimaryButton(
        'Next',
        onPressed: () => go(context, '/find-friends'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick Your\nInterests',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'Connect with people who share your interests and explore new possibilities by selecting your passions.',
            style: TextStyle(color: BalbColors.muted),
          ),
          for (final g in groups.entries) ...[
            Heading(g.key),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: g.value
                  .map(
                    (v) => FilterChip(
                      label: Text(
                        v.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      selected: s.interests.contains(v),
                      selectedColor: BalbColors.primary,
                      checkmarkColor: Colors.white,
                      onSelected: (_) => s.toggle(s.interests, v),
                      shape: const StadiumBorder(),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: 'Account Setup',
      bottom: PrimaryButton(
        'Next',
        onPressed: () {
          s.signedIn = true;
          s.save();
          home(context);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Friends',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'Easily connect with your friends from Facebook and Twitter or discover new ones from our suggestion list.',
            style: TextStyle(color: BalbColors.muted),
          ),
          const Heading('Import Friends'),
          for (final provider in ['Facebook', 'Twitter'])
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.blue,
                  child: Text(
                    provider == 'Facebook' ? 'f' : 't',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text('Import from $provider'),
                onTap: () => toast(
                  context,
                  'Connect $provider to import contacts. Suggested friends are available below.',
                ),
              ),
            ),
          const Heading('Suggested'),
          for (final (i, n) in [
            'Gerrard_Lin',
            'LeslieAlex_',
            'GuyHawk23',
            'Dianne Russell',
          ].indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                tileColor: BalbColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                leading: Avatar(index: i),
                title: Text(
                  n,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  [
                    'UI Design Enthusiast',
                    'Travel Youtuber',
                    'GGMU',
                    'Actress',
                  ][i],
                  style: const TextStyle(fontSize: 11, color: BalbColors.muted),
                ),
                trailing: FollowButton(
                  following: s.following.contains(n),
                  onPressed: () => s.toggle(s.following, n),
                ),
                onTap: () => go(context, '/user'),
              ),
            ),
        ],
      ),
    );
  }
}
