import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:application_job/src/Jobs/jobs_screen.dart';
import 'package:application_job/src/LoginPage/login_screen.dart';
import 'package:application_job/src/user_state.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Stream<User?> authStateChanges() {
    return const Stream.empty();
  }
}

class MockUser extends Mock implements User {}

void main() {
  late User user;
  late FirebaseAuth auth;

  setUp(() {
    user = MockUser();
    auth = MockFirebaseAuth();

    when(auth.authStateChanges())
        .thenAnswer((_) => Stream.fromIterable([null]));
  });

  testWidgets('test UserState', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: UserState(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration.zero);

      expect(find.byType(Login), findsOneWidget);

      await tester.runAsync(() async {
        await auth.signInWithEmailAndPassword(
            email: 'test@test.com', password: 'password');
      });

      await tester.pump(Duration.zero);

      expect(find.byType(JobScreen), findsOneWidget);
    });
  });
}
