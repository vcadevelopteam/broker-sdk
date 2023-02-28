import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> askGps() async {
  final status = await Permission.location.request();

  if (status == PermissionStatus.granted) return true;

  return false;
}

Future<bool> askGpsForIos() async {
  final serviceEnabled = await Geolocator.checkPermission() ;

  if (serviceEnabled==LocationPermission.always || serviceEnabled==LocationPermission.whileInUse  ) return true;

  return false;
}

Future<bool> askStorage() async {
  final status = await Permission.storage.request();

  if (status == PermissionStatus.granted) return true;

  return false;
}
