import 'package:f1/data/drivers_data.dart';
import 'package:f1/data/races_data.dart';
import 'package:f1/data/teams_data.dart';
import 'package:f1/screens/driver_details_screen.dart';
import 'package:f1/screens/team_details_screen.dart';
import 'package:f1/widgets/calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('team detail shows history, trophies, and achievements', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: TeamDetailsScreen(team: teamsData[1]),
      ),
    );

    expect(find.text('Team History'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Trophy Cabinet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Trophy Cabinet'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Major Achievements'),
      400,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Major Achievements'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('driver detail shows accurate career achievements', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: DriverDetailsScreen(driver: driversData.first),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Career Achievements'),
      400,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Career Achievements'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('2025 Formula 1 World Champion'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('2025 Formula 1 World Champion'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long race names fit a phone-width calendar card', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: CalendarCard(race: racesData.last),
          ),
        ),
      ),
    );

    expect(find.text('Abu Dhabi Grand Prix'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
