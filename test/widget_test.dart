// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show Scrollable;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:f1/main.dart';

void main() {
  testWidgets('App shows loading animation then loads home screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const F1App());

    expect(find.text('PREPARING THE GRID'), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('F1 2026'), findsWidgets);
    expect(find.text('Season Schedule'), findsNothing);
    expect(find.text('Teams'), findsWidgets);
    expect(find.text('VIEW WEEKEND  →'), findsOneWidget);
    expect(find.text('Races'), findsOneWidget);
    expect(find.text('Ranks'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('SHOP'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text(r'$89'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
