import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fyp/providers/authentication_provider.dart';

//unit testing
void main() {
  late Authentication systemUnderTest;
  setUp( (){
  systemUnderTest = MockAuthentication();
  });
  //grouping unit tests
  group('Login Units', () {
    //customer login test
    test('Successful customer login', () async {
      await systemUnderTest.login("test@test.com", "123456", 0);
      expect(systemUnderTest.userAuthenticated, true);
    });
    //business login test
    test('Successful business login', () async {
      await systemUnderTest.login("owner@owner.com", "123456", 1);
      expect(systemUnderTest.userAuthenticated, true);
    });
    //customer choosing wrong role
    test('Unsuccessful customer login with wrong role', () async {
      await systemUnderTest.login("test@test.com", "123456", 1);
      expect(systemUnderTest.userAuthenticated, false);
    });
    //business choosing wrong role
    test('Unsuccessful business login with wrong role', () async {
      await systemUnderTest.login("owner@owner.com", "123456", 0);
      expect(systemUnderTest.userAuthenticated, false);
    });
    //wrong/unregistered user email
    test('Unsuccessful login with wrong email', () async {
      await systemUnderTest.login("owner@wrong.com", "123456", 1);
      expect(systemUnderTest.userAuthenticated, false);
    });
    //wrong user password
    test('Unsuccessful login with wrong password', () async {
      await systemUnderTest.login("owner@owner.com", "wrong123", 1);
      expect(systemUnderTest.userAuthenticated, false);
    });
  });
}

//using Mockito to Mock the Authentication class
class MockAuthentication extends Mock implements Authentication {
  String _userToken = '';
  @override
  bool get userAuthenticated {
    //if there is a token and it didn't expire then the user is authenticated
    return theToken != null;
  }

  //get the token if it is not empty else returns null
  @override
  String? get theToken {
    if (_userToken != '') {
      return _userToken;
    }
    return null;
  }

  @override
  Future<void> login(String email, String password, int role) async {
    bool userVerified = await verifyUser(email, role);
    //stimulating the behaviour of the login method
    if (((email == "test@test.com" && password == "123456") || (email == "owner@owner.com" && password == "123456")) && userVerified) {
      _userToken = "NewlyGeneratedTokenFromFirebaseAuthentication";
    }
  }
  @override
  Future<bool> verifyUser(String gotEmail, int gotRole) {
    //customer is trying to login
    if(gotEmail == "test@test.com" &&  gotRole == 0){
      return Future(() => true);
    }
    //business is trying to login
    if(gotEmail == "owner@owner.com" &&  gotRole == 1){
      return Future(() => true);
    }
    //not valid
    return Future(() => false);
  }
}
