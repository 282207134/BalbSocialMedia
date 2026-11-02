import 'package:flutter/material.dart';

import 'core/store.dart';
import 'core/theme.dart';
import 'features/auth/auth_screens.dart';
import 'features/account/setup_screens.dart';
import 'features/account/account_screens.dart';
import 'features/feed/shell.dart';
import 'features/feed/feed_screen.dart';
import 'features/discover/discover_screen.dart';
import 'features/messages/message_screens.dart';
import 'features/post/post_screens.dart';
import 'features/media/media_screens.dart';
import 'shared/widgets.dart';

class BalbApp extends StatelessWidget {
  const BalbApp({
    super.key,
    required this.store,
    this.initialRoute = '/splash',
    this.navigatorKey,
  });
  final SocialStore store;
  final String initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  static const screens = <String, String>{
    '/splash': 'Splash',
    '/onboarding': 'Onboarding 1',
    '/onboarding-2': 'Onboarding 2',
    '/onboarding-3': 'Onboarding 3',
    '/sign-up': 'Sign up',
    '/sign-in': 'Sign in',
    '/recovery': 'Password Recovery',
    '/reset-code': 'Verification Code',
    '/new-password': 'Set New Password',
    '/password-success': 'Password Reset Success',
    '/confirmation': 'Confirmation Code',
    '/setup-name': 'Name and Username',
    '/complete-profile': 'Complete Profile',
    '/interests': 'Pick Interests',
    '/find-friends': 'Find Friends',
    '/home': 'Home V1',
    '/home-v2': 'Home V2',
    '/home-v3': 'Home V3',
    '/video': 'Home Video',
    '/live': 'Watch Live',
    '/story': 'Story',
    '/comments': 'Comments',
    '/notifications': 'Notifications',
    '/discover': 'Discover',
    '/search': 'Search',
    '/topics': 'All Topics',
    '/camera': 'Post Photo',
    '/gallery': 'Post Gallery',
    '/filter': 'Photo Filter',
    '/edit': 'Photo Edit',
    '/share': 'Share Post',
    '/messages': 'Messages',
    '/chat': 'Chat',
    '/call': 'Video Call',
    '/profile': 'My Profile',
    '/user': 'User Profile',
    '/settings': 'Settings',
    '/edit-profile': 'Edit Profile',
    '/saved': 'Saved Posts',
  };
  @override
  Widget build(BuildContext context) => StoreScope(
    store: store,
    child: MaterialApp(
      title: 'Balb',
      debugShowCheckedModeBanner: false,
      theme: balbTheme(),
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (route) => [
        routeFor(RouteSettings(name: route)),
      ],
      onGenerateRoute: routeFor,
      builder: (context, child) => ColoredBox(
        color: const Color(0xff101212),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child!,
          ),
        ),
      ),
    ),
  );
  static Route<dynamic> routeFor(RouteSettings settings) {
    final page = switch (settings.name) {
      '/splash' => const SplashScreen(),
      '/onboarding' => const OnboardingScreen(),
      '/onboarding-2' => const OnboardingScreen(initialPage: 1),
      '/onboarding-3' => const OnboardingScreen(initialPage: 2),
      '/sign-in' => const AuthScreen(step: AuthStep.signIn),
      '/sign-up' => const AuthScreen(step: AuthStep.signUp),
      '/recovery' => const AuthScreen(step: AuthStep.recovery),
      '/reset-code' => const AuthScreen(step: AuthStep.resetCode),
      '/new-password' => const AuthScreen(step: AuthStep.newPassword),
      '/password-success' => const AuthScreen(step: AuthStep.success),
      '/confirmation' => const AuthScreen(step: AuthStep.confirmation),
      '/setup-name' => const AuthScreen(step: AuthStep.name),
      '/complete-profile' => const EditProfileScreen(setup: true),
      '/edit-profile' => const EditProfileScreen(),
      '/interests' => const InterestsScreen(),
      '/find-friends' => const FriendsScreen(),
      '/home' => const ShellScreen(),
      '/home-v2' => const ShellScreen(homeStyle: 1),
      '/home-v3' => const ShellScreen(homeStyle: 2),
      '/discover' => const ShellScreen(initialTab: 1),
      '/messages' => const ShellScreen(initialTab: 3),
      '/profile' => const ShellScreen(initialTab: 4),
      '/user' => const UserScreen(),
      '/settings' => const SettingsScreen(),
      '/saved' => const SavedScreen(),
      '/setting-detail' => SettingDetailScreen(
        title: settings.arguments as String? ?? 'About Us',
      ),
      '/search' => const SearchScreen(),
      '/topics' => const TopicScreen(),
      '/topic' => TopicScreen(topic: settings.arguments as String? ?? 'Travel'),
      '/comments' => const CommentsScreen(),
      '/notifications' => const NotificationsScreen(),
      '/chat' => ChatScreen(name: settings.arguments as String? ?? 'Jesselin_'),
      '/camera' => const CameraScreen(),
      '/gallery' => const GalleryScreen(),
      '/filter' => const FilterScreen(),
      '/edit' => const FilterScreen(edit: true),
      '/share' => const ShareScreen(),
      '/video' => const MediaScreen(kind: 'video'),
      '/story' => const MediaScreen(kind: 'story'),
      '/live' => const MediaScreen(kind: 'live'),
      '/call' => const MediaScreen(kind: 'call'),
      '/post-detail' => PageFrame(
        title: 'Post',
        padding: EdgeInsets.zero,
        child: PostCard(
          id: settings.arguments as String? ?? 'alice',
          author: 'Alicestar',
          caption: 'Every moment tells a story.',
          images: [settings.arguments as String? ?? 'feed'],
        ),
      ),
      _ => const ShellScreen(),
    };
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }
}
