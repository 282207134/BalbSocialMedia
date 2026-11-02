import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'post_draft.dart';

class SocialStore extends ChangeNotifier {
  SocialStore({this.preferences});
  final SharedPreferences? preferences;
  String name = 'Diavanda Domenic',
      username = 'Diavandadome',
      bio = 'Food Photography Enthusiast',
      email = 'diavandadomenic@gmail.com',
      birthday = '';
  bool onboarded = false, signedIn = false;
  PostDraft draft = PostDraft();
  String profileAvatar = 'profile_avatar', profileCover = 'profile_cover';
  final Set<String> likes = {}, bookmarks = {}, following = {};
  final Set<String> interests = {
    'soccer',
    'badminton',
    'baseball',
    'mr beast',
    'bts',
  };
  final List<String> messages = [], comments = [];
  final Map<String, List<String>> threads = {};
  final List<Map<String, String>> posts = [];
  final Map<String, bool> settings = {
    'Notifications': true,
    'Private account': false,
  };

  static Future<SocialStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = SocialStore(preferences: prefs);
    final saved = prefs.getString('balb.v1');
    if (saved != null) {
      try {
        store.restore(jsonDecode(saved) as Map<String, dynamic>);
      } on FormatException {
        await prefs.remove('balb.v1');
      }
    }
    return store;
  }

  void restore(Map<String, dynamic> data) {
    name = data['name'] as String? ?? name;
    username = data['username'] as String? ?? username;
    bio = data['bio'] as String? ?? bio;
    email = data['email'] as String? ?? email;
    birthday = data['birthday'] as String? ?? birthday;
    profileAvatar = data['profileAvatar'] as String? ?? profileAvatar;
    profileCover = data['profileCover'] as String? ?? profileCover;
    onboarded = data['onboarded'] == true;
    signedIn = data['signedIn'] == true;
    for (final entry in {
      'likes': likes,
      'bookmarks': bookmarks,
      'following': following,
      'interests': interests,
    }.entries) {
      if (data[entry.key] is List) {
        entry.value
          ..clear()
          ..addAll((data[entry.key] as List).cast<String>());
      }
    }
    messages.addAll((data['messages'] as List? ?? []).cast<String>());
    for (final entry in (data['threads'] as Map? ?? {}).entries) {
      threads[entry.key as String] = (entry.value as List).cast<String>();
    }
    comments.addAll((data['comments'] as List? ?? []).cast<String>());
    posts.addAll(
      (data['posts'] as List? ?? []).map(
        (p) => Map<String, String>.from(p as Map),
      ),
    );
    settings.addAll(Map<String, bool>.from(data['settings'] as Map? ?? {}));
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'bio': bio,
    'email': email,
    'birthday': birthday,
    'profileAvatar': profileAvatar,
    'profileCover': profileCover,
    'onboarded': onboarded,
    'signedIn': signedIn,
    'likes': likes.toList(),
    'bookmarks': bookmarks.toList(),
    'following': following.toList(),
    'interests': interests.toList(),
    'messages': messages,
    'threads': threads,
    'comments': comments,
    'posts': posts,
    'settings': settings,
  };
  Future<void> save() async {
    notifyListeners();
    await preferences?.setString('balb.v1', jsonEncode(toJson()));
  }

  void toggle(Set<String> collection, String id) {
    collection.contains(id) ? collection.remove(id) : collection.add(id);
    save();
  }

  void send(String text, {String thread = 'Jesselin_'}) {
    if (text.trim().isNotEmpty) {
      (thread == 'Jesselin_' ? messages : threads.putIfAbsent(thread, () => []))
          .add(text.trim());
      save();
    }
  }

  void comment(String text) {
    if (text.trim().isNotEmpty) {
      comments.add(text.trim());
      save();
    }
  }

  void publishDraft() {
    posts.insert(0, {
      ...draft.toPost(),
      'id': 'post_${DateTime.now().microsecondsSinceEpoch}',
    });
    save();
  }
}

class StoreScope extends InheritedNotifier<SocialStore> {
  const StoreScope({
    super.key,
    required SocialStore store,
    required super.child,
  }) : super(notifier: store);
  static SocialStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
