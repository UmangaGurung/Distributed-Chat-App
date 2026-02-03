class RegisterResponse{
  String? _status;
  String? _response;

  RegisterResponse(String response, String status){
    this._response= response;
    this._status= status;
  }

  String get response => _response!;

  set response(String value) {
    _response = value;
  }

  String get status => _status!;

  set status(String value) {
    _status = value;
  }
}