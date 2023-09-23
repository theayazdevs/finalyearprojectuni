import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fyp/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //test
  testWidgets('Customer Side: END-TO-END-TEST', (widgetTester) async {
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
    //tap login button
    await widgetTester.tap(find.byKey(const Key('submit_btn_key')));
    await widgetTester.pumpAndSettle();
    //check if login was successful, the customer home page must have search box
    expect(find.byKey(const Key('search_key')), findsOneWidget);
    await Future.delayed(const Duration(seconds: 3));
    final listViewFinderOne = find.byKey(const Key('business_list_key'));
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
      //find the items list and click the first one
      final listViewFinderTwo =
          find.byKey(const Key('menu_categories_list_key'));
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
        //go back to view business menu screen
        //tap back button
        await widgetTester
            .tap(find.byKey(const Key('back_to_view_business_menu')));
        await widgetTester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3));
      }
      //go back to home screen
      //tap back button
      await widgetTester.tap(find.byKey(const Key('back_to_customer_home')));
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
    await widgetTester.tap(find.text('My Orders'));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    expect(find.text('Your Orders'), findsOneWidget);
    //Open the drawer
    //getting the state of the current Scaffold widget
    final scaffoldStateTwo = widgetTester.state<ScaffoldState>(find.byType(Scaffold));
    //opening the drawer using Scaffold state
    scaffoldStateTwo.openDrawer();
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //find a profile widget and tap it in the customer drawer
    await widgetTester.tap(find.text('Profile'));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    expect(find.text('Your Profile'), findsOneWidget);
    //Open the drawer
    //getting the state of the current Scaffold widget
    final scaffoldStateThree = widgetTester.state<ScaffoldState>(find.byType(Scaffold));
    //opening the drawer using Scaffold state
    scaffoldStateThree.openDrawer();
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
    //find logout widget and tap it in the customer drawer
    await widgetTester.tap(find.text('Logout'));
    await widgetTester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));
  });
}
