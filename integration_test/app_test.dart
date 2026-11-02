import 'package:balb_social/app.dart';
import 'package:balb_social/core/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android screen capture and core interaction flow', (
    tester,
  ) async {
    final store = SocialStore();
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      BalbApp(store: store, initialRoute: '/home', navigatorKey: navigator),
    );
    await tester.pumpAndSettle();
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final context = tester.element(find.byType(BalbApp));
    await Future.wait(
      manifest
          .listAssets()
          .where((a) => a.startsWith('assets/images/'))
          .map((a) => precacheImage(AssetImage(a), context)),
    );
    await binding.convertFlutterSurfaceToImage();
    for (final route in BalbApp.screens.keys) {
      navigator.currentState!.pushNamedAndRemoveUntil(route, (_) => false);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: route);
      await binding.takeScreenshot(route.substring(1));
    }
    for (final title in [
      'Privacy',
      'Notification',
      'Security',
      'Language',
      'Help',
      'About Us',
    ]) {
      navigator.currentState!.pushNamedAndRemoveUntil(
        '/setting-detail',
        (_) => false,
        arguments: title,
      );
      await tester.pumpAndSettle();
      await binding.takeScreenshot(
        'settings-${title.toLowerCase().replaceAll(' ', '-')}',
      );
    }
    navigator.currentState!.pushNamedAndRemoveUntil(
      '/topic',
      (_) => false,
      arguments: 'Travel',
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('topic-travel');
    navigator.currentState!.pushNamedAndRemoveUntil(
      '/post-detail',
      (_) => false,
      arguments: 'art',
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('post-detail');

    navigator.currentState!.pushNamedAndRemoveUntil('/home', (_) => false);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Like post').first);
    await tester.pumpAndSettle();
    expect(store.likes, contains('alice'));
    await tester.tap(find.byTooltip('Save post').first);
    await tester.pumpAndSettle();
    expect(store.bookmarks, contains('alice'));
    navigator.currentState!.pushNamed('/chat');
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Hello from the Android emulator',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(store.messages.last, 'Hello from the Android emulator');
    navigator.currentState!.pushNamed('/share');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'A moment from Balb');
    await tester.tap(find.widgetWithText(FilledButton, 'Share'));
    await tester.pumpAndSettle();
    expect(store.posts.single['caption'], 'A moment from Balb');
    await binding.takeScreenshot('published-post');
  });
}
