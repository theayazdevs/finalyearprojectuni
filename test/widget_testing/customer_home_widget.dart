import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/business_data_provider.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/customer_food_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:fyp/widgets/business_item_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

//widget testing
void main() {
  late Widget systemUnderTest;
  final sttProvider = SpeechToTextProvider(SpeechToText());
  final customerFoodProvider = MockViewBusiness();
  Widget widgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sttProvider),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          //CUSTOMER HOME SCREEN
          home: Scaffold(
            body: Padding(
                padding: const EdgeInsets.all(8),
                child:
                ListView.builder(
                  itemBuilder: (_, i) => Column(
                    children: [
                      BusinessItemWidget(
                        businessName: customerFoodProvider
                            .businessItems[i].businessName,
                        businessType: customerFoodProvider
                            .businessItems[i].businessType,
                        businessDoorNo: customerFoodProvider
                            .businessItems[i].businessDoorNo,
                        businessPostCode: customerFoodProvider
                            .businessItems[i].businessPostCode,
                        businessService: customerFoodProvider
                            .businessItems[i].deliveryOrCollection,
                        businessOpenTimes: customerFoodProvider
                            .businessItems[i].openTimes,
                        ownerID:
                        customerFoodProvider.businessItems[i].ownerID,
                      ),
                    ],
                  ),
                  itemCount: customerFoodProvider.businessItems.length,
                ),
              ),
          ),
        ),
      ),
    );
  }

  setUp(() async {
    systemUnderTest = widgetUnderTest();
  });

  //Customer
  group('Customer Home Screen', () {
    testWidgets('Check All Businesses widgets are present at customer home screen', (widgetTester) async {
      await customerFoodProvider.fetchAndSetBusiness();
      await widgetTester.pumpWidget(systemUnderTest);
      //print(widgetTester.allWidgets.toList());
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if food business text widget in uppercase letters is present
      //this is because the business name is shown in uppercase on screen
      expect(find.text('THEKFC'), findsOneWidget);
      expect(find.text('THEMCDONALD'), findsOneWidget);
    });
    testWidgets('Check All Businesses Details Accuracy', (widgetTester) async {
      await customerFoodProvider.fetchAndSetBusiness();
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if food business type widget is present
      expect(find.text('restaurant'), findsOneWidget);
      expect(find.text('takeaway'), findsOneWidget);
      //check if food business post code widget is present
      expect(find.text('ABC123'), findsOneWidget);
      expect(find.text('DEF456'), findsOneWidget);

    });
  });
}

//using Mockito to Mock the CustomerFoodProvider class
class MockViewBusiness extends Mock implements CustomerFoodProvider {
  List<BusinessData> _businessItems = [
    BusinessData(
        id: 'b1',
        businessName: 'theKFC',
        businessType: 'restaurant',
        businessDoorNo: '1',
        businessPostCode: 'ABC123',
        deliveryOrCollection: 'delivery and collection',
        openTimes: 'mon to fri, 6 to 10',
        ownerID: 'theOwner-1'),
    BusinessData(
        id: 'b2',
        businessName: 'theMcDonald',
        businessType: 'takeaway',
        businessDoorNo: '2',
        businessPostCode: 'DEF456',
        deliveryOrCollection: 'delivery and collection',
        openTimes: 'mon to fri, 4 to 11',
        ownerID: 'theOwner-2'),
  ];
  //to store the list of FoodCategoryProvider items
  List<FoodCategoryProvider> _items = [];
  //return list of BusinessData items
  @override
  List<BusinessData> get businessItems {
    //return a copy of items
    return [..._businessItems];
  }
  //return list of FoodCategoryProvider items
  @override
  List<FoodCategoryProvider> get items {
    //return a copy of items
    return [..._items];
  }
  @override
  Future<void> fetchAndSetBusiness() async {
    if (_businessItems.isNotEmpty || _businessItems!=[]) {
      _businessItems = _businessItems;
    } else {
      _businessItems = [];
    }
  }

  @override
  Future<void> fetchAndSetMenu(String ownerID) async {
    if(ownerID=='theOwner-1'){
      _items = [
        FoodCategoryProvider(id: 'c1', title: 'Pizza', itemsInCategory: [CategoryItemProvider(id: 'p1', categoryItemTitle: 'Margherita', categoryItemDescription: 'simple pizza', categoryItemPrice: 4.00)]),
        FoodCategoryProvider(id: 'c2', title: 'Burger', itemsInCategory: [CategoryItemProvider(id: 'b1', categoryItemTitle: 'Chicken', categoryItemDescription: 'simple chicken fillet burger', categoryItemPrice: 4.00)]),
      ];
    }
    else if(ownerID=='theOwner-2'){
      _items = [
        FoodCategoryProvider(id: 'c3', title: 'Pizza', itemsInCategory: [CategoryItemProvider(id: 'p1', categoryItemTitle: 'Chicken', categoryItemDescription: 'simple chicken pizza', categoryItemPrice: 5.00)]),
      ];
    }

  }
}
