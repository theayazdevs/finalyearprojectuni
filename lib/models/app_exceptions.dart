//uses an abstract class , Exception
class AppExceptions implements Exception {
  //variable to store the message
  final String message;
  //to get the error message
  AppExceptions(this.message);

  @override
  String toString() {
    //error message
    return message;
  }
}
