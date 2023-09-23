import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import './providers/authentication_provider.dart';
import './providers/foods_menu_provider.dart';
import './providers/business_data_provider.dart';
import './providers/business_details_provider.dart';
import './screens/view_category_items_screen.dart';
import './screens/edit_category_item_screen.dart';
import './screens/manage_category_item_screen.dart';
import './screens/edit_category_screen.dart';
import './screens/manage_menu_screen.dart';
import './screens/authentication_screen.dart';
import './screens/customer_screen.dart';
import './screens/business_screen.dart';
import './screens/business_details_screen.dart';
import './screens/edit_business_details_screen.dart';
import './screens/view_business_menu_screen.dart';
import './providers/customer_data_provider.dart';
import './providers/customer_details_provider.dart';
import './providers/customer_food_provider.dart';
import './providers/item_in_cart_provider.dart';
import './providers/orders_provider.dart';
import './screens/business_orders_screen.dart';
import './screens/buy_items_screen.dart';
import './screens/customer_cart_screen.dart';
import './screens/customer_details_screen.dart';
import './screens/customer_orders_screen.dart';
import './screens/edit_customer_details_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SpeechToText speech = SpeechToText();
  late SpeechToTextProvider speechProvider;

  @override
  void initState() {
    super.initState();
    speechProvider = SpeechToTextProvider(speech);
    //initializing voice recognition
    initializeVoiceRecognition();
  }

  Future<void> initializeVoiceRecognition() async {
    await speechProvider.initialize();
    //log('initialized the speech provider');
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<SpeechToTextProvider>.value(
            value: speechProvider,
          ),
          ChangeNotifierProvider.value(
            value: Authentication(),
          ),
          ChangeNotifierProvider.value(
            value: CustomerCart(),
          ),
          /*ChangeNotifierProvider.value(
            value: FoodsMenu(),
          ),*/
          ChangeNotifierProxyProvider<Authentication, BusinessDetails>(
            create: (ctx) => BusinessDetails(
              '',
              '',
              BusinessData(
                id: 'null',
                businessName: 'null',
                businessType: 'null',
                businessDoorNo: 'null',
                businessPostCode: 'null',
                deliveryOrCollection: 'null',
                openTimes: 'null',
                ownerID: 'null',
              ),
            ),
            //if old food menu is null then instantiate a new empty list
            update: (ctx, authObject, oldBusinessDetails) => BusinessDetails(
                authObject.theToken.toString(),
                authObject.theUserID.toString(),
                oldBusinessDetails == null
                    ? BusinessData(
                        id: 'null',
                        businessName: 'null',
                        businessType: 'null',
                        businessDoorNo: 'null',
                        businessPostCode: 'null',
                        deliveryOrCollection: 'null',
                        openTimes: 'null',
                        ownerID: 'null',
                      )
                    : oldBusinessDetails.businessData),
          ),
          ChangeNotifierProxyProvider<Authentication, CustomerDetails>(
            create: (ctx) => CustomerDetails(
              '',
              '',
              CustomerData(
                id: 'null',
                customerFirstName: 'null',
                customerLastName: 'null',
                customerDoorNo: 'null',
                customerPostCode: 'null',
                phoneNumber: 'null',
                userID: 'null',
              ),
            ),
            //if old food menu is null then instantiate a new empty list
            update: (ctx, authObject, oldCustomerDetails) => CustomerDetails(
                authObject.theToken.toString(),
                authObject.theUserID.toString(),
                oldCustomerDetails == null
                    ? CustomerData(
                        id: 'null',
                        customerFirstName: 'null',
                        customerLastName: 'null',
                        customerDoorNo: 'null',
                        customerPostCode: 'null',
                        phoneNumber: 'null',
                        userID: 'null',
                      )
                    : oldCustomerDetails.customerData),
          ),
          //this provider depends on the authentication provider that is why proxy is used, creating a dependency
          ChangeNotifierProxyProvider<Authentication, FoodsMenu>(
            create: (ctx) => FoodsMenu('', '', []),
            //if old food menu is null then instantiate a new empty list
            update: (ctx, authObject, oldFoodsMenu) => FoodsMenu(
                authObject.theToken.toString(),
                authObject.theUserID.toString(),
                oldFoodsMenu == null ? [] : oldFoodsMenu.getCategoryItems),
          ),
          ChangeNotifierProxyProvider<Authentication, CustomerFoodProvider>(
            create: (ctx) => CustomerFoodProvider('', '', [], []),
            //if old food menu is null then instantiate a new empty list
            update: (ctx, authObject, oldCustomerProvider) =>
                CustomerFoodProvider(
                    authObject.theToken.toString(),
                    authObject.theUserID.toString(),
                    oldCustomerProvider == null
                        ? []
                        : oldCustomerProvider.businessItems,
                    oldCustomerProvider == null
                        ? []
                        : oldCustomerProvider.getCategoryItems),
          ),
          ChangeNotifierProxyProvider<Authentication, AllOrders>(
            create: (ctx) => AllOrders('', '', [], []),
            //if old food menu is null then instantiate a new empty list
            update: (ctx, authObject, oldOrders) => AllOrders(
              authObject.theToken.toString(),
              authObject.theUserID.toString(),
              oldOrders == null ? [] : oldOrders.getBusinessOrders,
              oldOrders == null ? [] : oldOrders.getCustomerOrders,
            ),
          ),
        ],
        // rebuilds whenever authentication changes
        child: Consumer<Authentication>(
            builder: (cntxt, authentication, _) => MaterialApp(
                  //to hide the debug banner
                  debugShowCheckedModeBanner: false,
                  title: 'The Food Ordering App',
                  theme: ThemeData(
                    colorScheme:
                        ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)
                            .copyWith(secondary: Colors.deepOrange),
                  ),
                  home:
                      // if authenticated as customer?
                      (authentication.userAuthenticated &&
                              authentication.userRoleVerified == 0)
                          // true, authenticated as customer
                          ? const CustomerScreen()
                          //false, else if, authenticated as business?
                          : (authentication.userAuthenticated &&
                                  authentication.userRoleVerified == 1)
                              //true, authenticated as business
                              ? const BusinessScreen()
                              //false, else stay on login screen, or try to auto login from authentication screen
                              : const AuthenticationScreen(),
                  routes: {
                    //initializing routes to other screens in the application
                    BusinessScreen.routeName: (ctx) => const BusinessScreen(),
                    ManageMenuScreen.routeName: (ctx) =>
                        const ManageMenuScreen(),
                    EditCategoryScreen.routeName: (ctx) =>
                        const EditCategoryScreen(),
                    ManageCategoryItemScreen.routeName: (ctx) =>
                        const ManageCategoryItemScreen(),
                    EditCategoryItemScreen.routeName: (ctx) =>
                        const EditCategoryItemScreen(),
                    ViewCategoryItemScreen.routeName: (ctx) =>
                        const ViewCategoryItemScreen(),
                    BusinessDetailsScreen.routeName: (ctx) =>
                        const BusinessDetailsScreen(),
                    EditBusinessDetailsScreen.routeName: (ctx) =>
                        const EditBusinessDetailsScreen(),
                    CustomerScreen.routeName: (ctx) => const CustomerScreen(),
                    ViewBusinessMenuScreen.routeName: (ctx) =>
                        const ViewBusinessMenuScreen(),
                    BuyItemsScreen.routeName: (ctx) => const BuyItemsScreen(),
                    CartScreen.routeName: (ctx) => CartScreen(),
                    CustomerOrdersScreen.routeName: (ctx) =>
                        const CustomerOrdersScreen(),
                    BusinessOrdersScreen.routeName: (ctx) =>
                        const BusinessOrdersScreen(),
                    CustomerDetailsScreen.routeName: (ctx) =>
                        const CustomerDetailsScreen(),
                    EditCustomerDetailsScreen.routeName: (ctx) =>
                        const EditCustomerDetailsScreen(),
                  },
                )));
  }
}
