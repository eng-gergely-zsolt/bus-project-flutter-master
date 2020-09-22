import 'package:geolocator/geolocator.dart';

class UserData {
  static final UserData _userData = new UserData._internal();

  Position userLocation;

  factory UserData() {
    return _userData;
  }

  UserData._internal();
}

final userData = UserData();
