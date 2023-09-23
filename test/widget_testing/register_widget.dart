import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/main.dart';

//widget testing
void main() {
  late MyApp systemUnderTest;
  setUp(() {
    systemUnderTest = const MyApp();
  });
  //Email
  group('Email Widget Tests', () {
    testWidgets('Email Field Widget Valid Email', (widgetTester) async {
      //set up the sign up screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if sign up screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //switchRegLog_key
      //pressing the registration button to move to sign up screen
      final switchBtn = find.byKey(const Key('switchRegLog_key'));
      await widgetTester.tap(switchBtn);
      await widgetTester.pumpAndSettle();
      //check if email field is present on screen
      expect(find.byKey(const Key('email_field_key')) , findsOneWidget);
      //input an valid email address to the email field
      await widgetTester.enterText(find.byKey(const Key('email_field_key')), 'test@test.com');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //check if email input successfully
      expect(find.text('test@test.com'), findsOneWidget);
      //find sign up button on screen
      final signUpBtn = find.byKey(const Key('submit_btn_key'));
      //press the signUpBtn button to trigger validation
      await widgetTester.tap(signUpBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Invalid email!'), findsNothing);
    });
    testWidgets('Email Field Widget Invalid Email', (widgetTester) async {
      //set up the sign-up screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if sign-up screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //pressing the registration button to move to sign up screen
      final switchBtn = find.byKey(const Key('switchRegLog_key'));
      await widgetTester.tap(switchBtn);
      await widgetTester.pumpAndSettle();
      //check if email field is present on screen
      expect(find.byKey(const Key('email_field_key')) , findsOneWidget);
      //input an in-valid email address to the email field
      await widgetTester.enterText(find.byKey(const Key('email_field_key')), 'testtestcom');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //check if email input successfully
      expect(find.text('testtestcom'), findsOneWidget);
      //find sign-up button on screen
      final signUpBtn = find.byKey(const Key('submit_btn_key'));
      //press the sign-up button to trigger validation
      await widgetTester.tap(signUpBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Invalid email!'), findsOneWidget);
    });
  });

  //Password
  group('Password Widget Tests', () {
    testWidgets('Password Field Widget Valid Password', (widgetTester) async {
      //set up the sign-up screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if sign-up screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //pressing the registration button to move to sign up screen
      final switchBtn = find.byKey(const Key('switchRegLog_key'));
      await widgetTester.tap(switchBtn);
      await widgetTester.pumpAndSettle();
      //check if Password field is present on screen
      expect(find.byKey(const Key('password_field_key')) , findsOneWidget);
      //input a valid Password
      await widgetTester.enterText(find.byKey(const Key('password_field_key')), '123456');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //check if Password input successfully
      expect(find.text('123456'), findsOneWidget);
      //find sign-up button on screen
      final signUpBtn = find.byKey(const Key('submit_btn_key'));
      //press the sign-up button to trigger validation
      await widgetTester.tap(signUpBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Password is too short!'), findsNothing);
    });
    testWidgets('Password Field Widget Invalid Password', (widgetTester) async {
      //set up the sign-up screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if sign-up screen displaying correctly
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
      //find sign-up button on screen
      final signUpBtn = find.byKey(const Key('submit_btn_key'));
      //press the sign-up button to trigger validation
      await widgetTester.tap(signUpBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Password is too short!'), findsOneWidget);
    });
  });
  //Confirm Password
  group('Confirm Password Widget Tests', () {
    testWidgets('Confirm Password must match with password input before', (widgetTester) async {
      //set up the sign-up screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if sign-up screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //pressing the registration button to move to sign up screen
      final switchBtn = find.byKey(const Key('switchRegLog_key'));
      await widgetTester.tap(switchBtn);
      await widgetTester.pumpAndSettle();
      //inputting password into password field
      await widgetTester.enterText(find.byKey(const Key('password_field_key')), '123456');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 1));
      //check if Password field is present on screen
      expect(find.byKey(const Key('confirmPass_field_key')) , findsOneWidget);
      //input a matching password in confirm password
      await widgetTester.enterText(find.byKey(const Key('confirmPass_field_key')), '123456');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //find sign-up button on screen
      final registerBtn = find.byKey(const Key('submit_btn_key'));
      //press the sign-up button to trigger validation
      await widgetTester.tap(registerBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Passwords do not match!'), findsNothing);
    });
    testWidgets('Confirm Password do not match with password input before', (widgetTester) async {
      //set up the sign-up screen
      //await widgetTester.pumpWidget(const MyApp());
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if sign-up screen displaying correctly
      expect(find.text('The Food Ordering App') , findsOneWidget);
      //pressing the registration button to move to sign up screen
      final switchBtn = find.byKey(const Key('switchRegLog_key'));
      await widgetTester.tap(switchBtn);
      await widgetTester.pumpAndSettle();
      //inputting password into password field
      await widgetTester.enterText(find.byKey(const Key('password_field_key')), '123456');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 1));
      //check if Password field is present on screen
      expect(find.byKey(const Key('confirmPass_field_key')) , findsOneWidget);
      //input a matching password in confirm password
      await widgetTester.enterText(find.byKey(const Key('confirmPass_field_key')), '789012');
      await widgetTester.pump();
      await widgetTester.testTextInput.receiveAction(TextInputAction.done);
      await widgetTester.pump(const Duration(seconds: 2));
      //find sign-up button on screen
      final registerBtn = find.byKey(const Key('submit_btn_key'));
      //press the sign-up button to trigger validation
      await widgetTester.tap(registerBtn);
      await widgetTester.pumpAndSettle();
      //test if validation work as expected
      expect(find.text('Passwords do not match!'), findsOneWidget);
    });
  });
}
