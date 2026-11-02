import 'package:balb_social/app.dart';
import 'package:balb_social/core/store.dart';
import 'package:balb_social/core/post_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Activity and conversations survive a local storage reload', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await SocialStore.load();
    s.username = 'balb_creator';
    s.toggle(s.likes, 'alice');
    s.toggle(s.following, 'Alicestar');
    s.send('Hello');
    s.send('Other conversation', thread: 'Gerrard');
    s.comment('Beautiful!');
    s.posts.add(
      (PostDraft()
            ..caption = 'Sunset'
            ..filter = 1
            ..brightness = .3)
          .toPost(),
    );
    await s.save();
    final restored = await SocialStore.load();
    expect(restored.username, 'balb_creator');
    expect(restored.likes, contains('alice'));
    expect(restored.following, contains('Alicestar'));
    expect(restored.messages, ['Hello']);
    expect(restored.threads['Gerrard'], ['Other conversation']);
    expect(restored.comments, ['Beautiful!']);
    expect(restored.posts.single['filter'], '1');
  });
  for (final size in [const Size(428, 926), const Size(360, 780)]) {
    testWidgets('All screens render without layout exceptions at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final route in BalbApp.screens.keys) {
        await tester.pumpWidget(
          BalbApp(key: UniqueKey(), store: SocialStore(), initialRoute: route),
        );
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
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: route);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      }
    });
  }
  testWidgets('Sign in validates fields and enters the feed', (tester) async {
    tester.view.physicalSize = const Size(428, 926);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final s = SocialStore();
    await tester.pumpWidget(BalbApp(store: s, initialRoute: '/sign-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'creator@balb.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'pass1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(s.signedIn, isTrue);
    expect(find.text('balb photo'), findsOneWidget);
  });
  testWidgets('Publishing a draft updates the feed', (tester) async {
    tester.view.physicalSize = const Size(428, 926);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final s = SocialStore();
    await tester.pumpWidget(BalbApp(store: s, initialRoute: '/share'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'My first Balb moment',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Share'));
    await tester.pumpAndSettle();
    expect(s.posts.single['caption'], 'My first Balb moment');
    expect(find.text('My first Balb moment'), findsOneWidget);
  });
}
