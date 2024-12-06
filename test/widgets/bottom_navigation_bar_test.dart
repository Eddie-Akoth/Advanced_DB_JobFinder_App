import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:application_job/src/user_state.dart';
import 'package:application_job/src/constants/colors.dart';
import 'package:application_job/src/Search/search_companies.dart';
import 'package:application_job/src/Search/profile_company.dart';
import 'package:application_job/src/Jobs/upload_job.dart';
import 'package:application_job/src/Jobs/jobs_screen.dart';
import 'package:application_job/src/widgets/bottom_navigation_bar.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late BottomNavigationBarForApp bottomNavigationBarForApp;
  late AllWorkersScreen allWorkersScreen;
  setUp(() {
    bottomNavigationBarForApp = BottomNavigationBarForApp(indexNum: 0);
    allWorkersScreen = const AllWorkersScreen();
  });

  group('The BottomNavigationForApp class that is responsible for Navigation',
      () {
    testWidgets('test showDialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.text('Press Me')),
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Dialog Title'),
                        content: Text('Dialog Content'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Press Me'),
              ),
            ),
          ),
        ),
      );

      // Tap the button.
      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed.
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Dialog Content'), findsOneWidget);

      // Tap the OK button.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify that the dialog is dismissed.
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('CurvedNavigationBar to ensure it is returned',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => bottomNavigationBarForApp,
            ),
          ),
        ),
      );

      expect(find.byType(CurvedNavigationBar), findsOneWidget);

      // Verify that the Icons are displayed
      expect(find.bySubtype<Icon>(), findsWidgets);

      // Tap the second item in the navigation bar
      await tester.tap(find.bySubtype<Navigator>());
      await tester.pump();

      // Verify that the correct page was navigated to
      // final allWorkersScreen = AllWorkersScreen();
      // await tester.pumpWidget(MaterialApp(home: allWorkersScreen));
      // expect(find.byType(TextField), findsOneWidget);
    });
  });
}
