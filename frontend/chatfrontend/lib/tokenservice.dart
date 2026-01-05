import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService extends AsyncNotifier<String?> {
  final _storage = const FlutterSecureStorage();

  bool isLoggedIn= false;

  String get token => state.requireValue ?? '';

  @override
  FutureOr<String?> build() async{
    try{
      final token= await _storage.read(key: 'auth_token');
      if (token==null || JwtDecoder.isExpired(token)){
        await _storage.delete(key: 'auth_token');
        return null;
      }
      return token;
    }catch(e){
      print("Error loading token: $e" );
      await _storage.delete(key: 'auth_token');
      return null;
    }
  }

  bool get isAuthenticated {
    final token= state.value;
    if (token==null){
      return false;
    }
    if (JwtDecoder.isExpired(token)){
      return false;
    }
    return true;
  }

  Future<void> assignToken({required String token}) async {
    await clearToken();
    await _storage.write(key: 'auth_token', value: token);
    state= AsyncData(token);
    print("token assigned: ${token}");
  }

  Map<String, dynamic> tokenDecode() {
    try {
      final token= state.value;
      if (token!=null){
        Map<String, dynamic> claims = JwtDecoder.decode(token);
        print(claims);
        return claims;
      }
      return {};
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<void> clearToken() async{
    state= const AsyncData(null);
    await _storage.delete(key: 'auth_token');
  }
}
