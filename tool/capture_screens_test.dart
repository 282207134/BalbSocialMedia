import 'package:balb_social/app.dart';
import 'package:balb_social/core/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final (name, path) in [
      ('Poppins', 'assets/fonts/Poppins-SemiBold.ttf'),
      ('Jakarta', 'assets/fonts/PlusJakartaSans.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(name)..addFont(rootBundle.load(path))).load();
    }
  });
  Future<void> capture(
    WidgetTester tester,
    String route, {
    String? name,
    Object? arguments,
    SocialStore? store,
    List<String>? fields,
    bool typing = false,
  }) async {
    tester.view.physicalSize = const Size(428, 926);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    final key = GlobalKey();
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: BalbApp(
          key: UniqueKey(),
          store: store ?? SocialStore(),
          initialRoute: route,
          navigatorKey: nav,
        ),
      ),
    );
    if (arguments != null) {
      nav.currentState!.pushNamedAndRemoveUntil(
        route,
        (_) => false,
        arguments: arguments,
      );
    }
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final context = tester.element(find.byType(BalbApp));
      await Future.wait(
        manifest
            .listAssets()
            .where((a) => a.startsWith('assets/images/'))
            .map((a) => precacheImage(AssetImage(a), context)),
      );
    });
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    if (fields != null) {
      for (final (i, value) in fields.indexed) {
        await tester.enterText(find.byType(TextField).at(i), value);
      }
      if (!typing) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull, reason: route);
    await expectLater(
      find.byKey(key),
      matchesGoldenFile(
        '../docs/screenshots/${name ?? route.substring(1)}.png',
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  for (final route in BalbApp.screens.keys) {
    testWidgets('Capture $route', (tester) async {
      await capture(tester, route);
    });
  }
  for (final entry in {
    '/sign-in': ['creator@balb.app', 'balb1234'],
    '/sign-up': ['creator@balb.app', 'balb1234', 'balb1234'],
    '/recovery': ['creator@balb.app'],
    '/reset-code': ['1', '2', '3', '4'],
    '/new-password': ['newbalb1234', 'newbalb1234'],
    '/confirmation': ['1', '2', '3', '4'],
    '/setup-name': ['Diavanda Domenic', 'diavandadome'],
  }.entries) {
    for (final typing in [true, false]) {
      testWidgets(
        'Capture ${entry.key} ${typing ? 'typing' : 'active'}',
        (tester) async => capture(
          tester,
          entry.key,
          name: '${entry.key.substring(1)}-${typing ? 'typing' : 'active'}',
          fields: entry.value,
          typing: typing,
        ),
      );
    }
  }
  for (final title in [
    'Privacy',
    'Notification',
    'Security',
    'Language',
    'Help',
    'About Us',
  ]) {
    testWidgets('Capture settings $title', (tester) async {
      await capture(
        tester,
        '/setting-detail',
        name: 'settings-${title.toLowerCase().replaceAll(' ', '-')}',
        arguments: title,
      );
    });
  }
  testWidgets(
    'Capture topic',
    (tester) async =>
        capture(tester, '/topic', name: 'topic-travel', arguments: 'Travel'),
  );
  testWidgets(
    'Capture post detail',
    (tester) async =>
        capture(tester, '/post-detail', name: 'post-detail', arguments: 'art'),
  );
  testWidgets(
    'Capture saved posts',
    (tester) async => capture(
      tester,
      '/saved',
      name: 'saved-populated',
      store: SocialStore()..bookmarks.add('alice'),
    ),
  );
  testWidgets('Capture published post', (tester) async {
    final s = SocialStore();
    s.draft.caption = 'A moment from Balb';
    s.draft.filter = 1;
    s.publishDraft();
    await capture(tester, '/home', name: 'published-post', store: s);
  });
  testWidgets(
    'Capture chat after sending',
    (tester) async => capture(
      tester,
      '/chat',
      name: 'chat-sent',
      store: SocialStore()..send('See you at Coachella!'),
    ),
  );
}
