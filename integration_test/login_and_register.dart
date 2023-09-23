import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fyp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //test
  testWidgets('Login and Registration integration testing', (widgetTester) async {
    app.main();
    await widgetTester.pumpAndSettle();
    //expect widgets on login screen screen
    expect(find.text('The Food Ordering App'), findsOneWidget);
    expect(find.text('E-Mail'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('REGISTER INSTEAD'), findsOneWidget);
    //turn off the auto-listener feature
    await widgetTester.tap(find.byKey(const Key('autolistener_key')));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //input email
    await widgetTester.enterText(
        find.byKey(const Key('email_field_key')), 'test@test.com');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //input password
    await widgetTester.enterText(
        find.byKey(const Key('password_field_key')), '123456');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    await widgetTester.pump();
    //tapping on customer role by determining the position of the
    //toggle switch and tapping on left = customer
    //await widgetTester.tapAt(const Offset(150, 300));
    final finder = find.byKey(const Key('role_toggle_key'));
    final topLeft = widgetTester.getTopLeft(finder);
    final bottomRight = widgetTester.getBottomRight(finder);
    final x = (topLeft.dx + bottomRight.dx) / 2;
    final y = (topLeft.dy + bottomRight.dy) / 2;
    await widgetTester.tapAt(Offset((x - 50), y));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //tap to go to registration screen
    //await widgetTester.tap(find.text('REGISTER INSTEAD'));
    await widgetTester.tap(find.byKey(const Key('switchRegLog_key')));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //expect widgets on login screen screen
    expect(find.text('The Food Ordering App'), findsOneWidget);
    expect(find.text('E-Mail'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
    expect(find.text('SIGN IN INSTEAD'), findsOneWidget);
    //input confirm password
    await widgetTester.enterText(
        find.byKey(const Key('confirmPass_field_key')), '123456');
    await widgetTester.testTextInput.receiveAction(TextInputAction.done);
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //tap to go back to login screen
    await widgetTester.tap(find.byKey(const Key('switchRegLog_key')));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
