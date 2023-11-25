import 'package:google_sign_in/google_sign_in.dart';

abstract class loginManager{
  Future<bool> login();
  Future<bool> logout();
}