import 'package:chatfrontend/loginresult.dart';

class GoogleRegisterResponse{
  String? _status;
  String? _response;
  LoginResult? _loginResult;

  GoogleRegisterResponse(String response, String status, LoginResult loginResult){
    _response= response;
    _status= status;
    _loginResult= loginResult;
  }

  String get response => _response!;

  set response(String value) {
    _response = value;
  }

  String get status => _status!;

  set status(String value) {
    _status = value;
  }

  LoginResult get loginResult => _loginResult!;

  set loginResult(LoginResult value){
    _loginResult = value;
  }
}