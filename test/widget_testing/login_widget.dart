import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/main.dart';

//widget testing
void main() {
  //Email
  group('Email Widget Tests', () {
    testWidgets('Email Field Widget Valid Email', (widgetTester) async {
      //set up the login screen
      await widgetTester.pumpWidget(const MyApp());
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if login screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //check if email field is present on screen
      expect(find.byKey(const Key('email_field_key')) , findsOneWidget);
      //input an valid email address to the email field
      await widgetTester.enterText(find.byKey(const Key('email_field_key')), 'test@test.com');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //check if email input successfully
      expect(find.text('test@test.com'), findsOneWidget);
      //find login button on screen
      final loginBtn = find.byKey(const Key('submit_btn_key'));
      //press the login button to trigger validation
      await widgetTester.tap(loginBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Invalid email!'), findsNothing);
    });
    testWidgets('Email Field Widget Invalid Email', (widgetTester) async {
      //set up the login screen
      await widgetTester.pumpWidget(const MyApp());
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if login screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //check if email field is present on screen
      expect(find.byKey(const Key('email_field_key')) , findsOneWidget);
      //input an in-valid email address to the email field
      await widgetTester.enterText(find.byKey(const Key('email_field_key')), 'testtestcom');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //check if email input successfully
      expect(find.text('testtestcom'), findsOneWidget);
      //find login button on screen
      final loginBtn = find.byKey(const Key('submit_btn_key'));
      //press the login button to trigger validation
      await widgetTester.tap(loginBtn);
      await widgetTester.pumpAndSettle();
      //expect(find.text('Invalid email!'), findsOneWidget);
      //test if validation work as expected
      expect(find.text('Invalid email!'), findsOneWidget);
    });
  });

  //Password
  group('Password Widget Tests', () {
    testWidgets('Password Field Widget Valid Password', (widgetTester) async {
      //set up the login screen
      await widgetTester.pumpWidget(const MyApp());
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if login screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //check if Password field is present on screen
      expect(find.byKey(const Key('password_field_key')) , findsOneWidget);
      //input a valid Password
      await widgetTester.enterText(find.byKey(const Key('password_field_key')), '123456');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //check if Password input successfully
      expect(find.text('123456'), findsOneWidget);
      //find login button on screen
      final loginBtn = find.byKey(const Key('submit_btn_key'));
      //press the login button to trigger validation
      await widgetTester.tap(loginBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Password is too short!'), findsNothing);
    });
    testWidgets('Password Field Widget Invalid Password', (widgetTester) async {
      //set up the login screen
      await widgetTester.pumpWidget(const MyApp());
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if login screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //check if Password field is present on screen
      expect(find.byKey(const Key('password_field_key')) , findsOneWidget);
      //input an in-valid Password to the Password field
      await widgetTester.enterText(find.byKey(const Key('password_field_key')), '123');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //check if Password input successfully
      expect(find.text('123'), findsOneWidget);
      //find login button on screen
      final loginBtn = find.byKey(const Key('submit_btn_key'));
      //press the login button to trigger validation
      await widgetTester.tap(loginBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Password is too short!'), findsOneWidget);
    });
  });
}
