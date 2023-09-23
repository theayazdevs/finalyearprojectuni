import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fyp/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //test
  testWidgets('Business Side: END-TO-END-TEST', (widgetTester) async {
    app.main();
    await widgetTester.pumpAndSettle();
    expect(find.text('The Food Ordering App'), findsOneWidget);
    await Future.delayed(const Duration(seconds: 3));
    //turn off the auto-listener feature
    await widgetTester.tap(find.byKey(const Key('autolistener_key')));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //remove stored data
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('email');
    sharedPreferences.remove('password');
    sharedPreferences.remove('role');
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //input email
    await widgetTester.enterText(
        find.byKey(const Key('email_field_key')), 'owner@owner.com');
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
    //toggle switch and tapping on right = business
    //await widgetTester.tapAt(const Offset(150, 300));
    final finder = find.byKey(const Key('role_toggle_key'));
    final topLeft = widgetTester.getTopLeft(finder);
    final bottomRight = widgetTester.getBottomRight(finder);
    final x = (topLeft.dx + bottomRight.dx) / 2;
    final y = (topLeft.dy + bottomRight.dy) / 2;
    await widgetTester.tapAt(Offset((x+50), y));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //tap login button
    await widgetTester.tap(find.byKey(const Key('submit_btn_key')));
    await widgetTester.pumpAndSettle();
    //check if login was successful, the business page must show "Your Menu" text
    expect(find.text('Your Menu'), findsOneWidget);
    await Future.delayed(const Duration(seconds: 3));
    final listViewFinderOne = find.byKey(const Key('category_list_business'));
    //tap the first item in the list if not empty
    if (widgetTester.widgetList(listViewFinderOne).isNotEmpty) {
      final firstItem = find
          .descendant(
        of: listViewFinderOne,
        matching: find.byType(ListTile),
      )
          .first;
      await widgetTester.tap(firstItem);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 5));
        //go back to business home
        //tap back button
        await widgetTester
            .tap(find.byKey(const Key('back_to_business_home')));
        await widgetTester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3));
    }
    //Open the drawer
    //getting the state of the current Scaffold widget
    final scaffoldStateOne = widgetTester.state<ScaffoldState>(find.byType(Scaffold));
    //opening the drawer using Scaffold state
    scaffoldStateOne.openDrawer();
    // OR OPEN DRAWER BY CLICKING ON THE MENU BUTTON MANUALLY
    //await widgetTester.tapAt(const Offset(50, 50));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //navigation
    //find a my orders widget and tap it in the customer drawer
    await widgetTester.tap(find.text('Orders'));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    expect(find.text('Orders Received'), findsOneWidget);
    //Open the drawer
    //getting the state of the current Scaffold widget
    final scaffoldStateTwo = widgetTester.state<ScaffoldState>(find.byType(Scaffold));
    //opening the drawer using Scaffold state
    scaffoldStateTwo.openDrawer();
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //find a profile widget and tap it in the customer drawer
    await widgetTester.tap(find.text('Manage'));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    expect(find.text('Manage Your Menu'), findsOneWidget);
    final listViewFinderTwo = find.byKey(const Key('category_list_manage'));
    //tap the first item in the list if not empty
    if (widgetTester.widgetList(listViewFinderTwo).isNotEmpty) {
      final firstItem = find
          .descendant(
        of: listViewFinderTwo,
        matching: find.byType(ListTile),
      )
          .first;
      await widgetTester.tap(firstItem);
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 5));
      //go back to business manage menu screen
      //tap back button
      await widgetTester
          .tap(find.byKey(const Key('back_to_business_manage')));
      await widgetTester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
    }
    //Open the drawer
    //getting the state of the current Scaffold widget
    final scaffoldStateThree = widgetTester.state<ScaffoldState>(find.byType(Scaffold));
    //opening the drawer using Scaffold state
    scaffoldStateThree.openDrawer();
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //find a profile widget and tap it in the customer drawer
    await widgetTester.tap(find.text('Profile'));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    expect(find.text('Your Business Profile'), findsOneWidget);
    //Open the drawer
    //getting the state of the current Scaffold widget
    final scaffoldStateFour = widgetTester.state<ScaffoldState>(find.byType(Scaffold));
    //opening the drawer using Scaffold state
    scaffoldStateFour.openDrawer();
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //find logout widget and tap it in the customer drawer
    await widgetTester.tap(find.text('Logout'));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
  });
}
