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
  group('Sign Up Units', () {
    //customer register test
    test('Successful customer Registration', () async {
      await systemUnderTest.signup("test@test.com", "123456", 0);
      expect(systemUnderTest.userAuthenticated, true);
    });
    //business register test
    test('Successful business Registration', () async {
      await systemUnderTest.signup("owner@owner.com", "123456", 1);
      expect(systemUnderTest.userAuthenticated, true);
    });
    //No role chosen, equal to 3
    test('Unsuccessful Registration, No role', () async {
      await systemUnderTest.signup("test@test.com", "123456", 3);
      expect(systemUnderTest.userAuthenticated, false);
    });
    //email already registered
    test('Unsuccessful Registration, Email already registered', () async {
      await systemUnderTest.signup("already@registered.com", "123456", 1);
      expect(systemUnderTest.userAuthenticated, false);
    });
    //password short, less than 6 characters
    test('Unsuccessful login with short password', () async {
      await systemUnderTest.signup("owner@owner.com", "wrong", 1);
      expect(systemUnderTest.userAuthenticated, false);
    });
  });
}

//using Mockito to Mock the Authentication class
class MockAuthentication extends Mock implements Authentication {
  String _userToken = '';
  String emailAlreadyRegistered = "already@registered.com";
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
  Future<void> signup(String email, String password, int role) async {
    if (email != "" && password != "" && role !=3 && email!=emailAlreadyRegistered && password.length>5)  {
      _userToken = "NewlyGeneratedTokenFromFirebaseAuthentication";
    }
    else{
    }
  }
}
