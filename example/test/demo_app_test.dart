import 'package:flutter_test/flutter_test.dart';
import 'package:rcaferati_flutter_awesome_button_example/main.dart';

void main() {
  Future<void> pumpDemoSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets(
    'switches tabs, navigates themed screens, and preserves themed state',
    (tester) async {
      await tester.pumpWidget(const AwesomeButtonExampleApp());
      await pumpDemoSettle(tester);

      expect(find.text('Basic Theme'), findsOneWidget);
      expect(find.text('COMMON'), findsOneWidget);
      expect(find.text('TEXT TRANSITION'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await pumpDemoSettle(tester);

      expect(find.text('Bojack Theme'), findsOneWidget);
      expect(find.text('Prev'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await pumpDemoSettle(tester);

      expect(find.text('Cartman Theme'), findsOneWidget);

      await tester.tap(find.text('Progress'));
      await pumpDemoSettle(tester);

      expect(find.text('Progress Buttons'), findsOneWidget);
      expect(find.text('LABELED BUTTONS'), findsOneWidget);
      expect(find.text('Flat Progress'), findsOneWidget);

      await tester.tap(find.text('Social'));
      await pumpDemoSettle(tester);

      expect(find.text('Social Buttons'), findsOneWidget);
      expect(find.text('ICONED BUTTONS'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);

      await tester.tap(find.text('Themed Buttons'));
      await pumpDemoSettle(tester);

      expect(find.text('Cartman Theme'), findsOneWidget);

      await tester.tap(find.text('Prev'));
      await pumpDemoSettle(tester);

      expect(find.text('Bojack Theme'), findsOneWidget);

      await tester.tap(find.text('Prev'));
      await pumpDemoSettle(tester);

      expect(find.text('Basic Theme'), findsOneWidget);
    },
  );
}
