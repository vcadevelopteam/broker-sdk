import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> askGps() async {
  final status = await Permission.location.request();

  if (status == PermissionStatus.granted) return true;

  return false;
}

Future<bool> gpsVerification(BuildContext context) async {
  final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    if (context.mounted) {
      showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
                title: Text("GPS no activado"),
                content: Text(
                    "Por favor verifique que su GPS esté activo e intete nuevamente"),
              ));
    }
  }

  return serviceEnabled;
}

Future<bool> askGpsForIos() async {
  // final service = await Geolocator.requestPermission();
  final serviceEnabled = await Geolocator.checkPermission();

  if (serviceEnabled == LocationPermission.always ||
      serviceEnabled == LocationPermission.whileInUse) return true;

  return false;
}

Future<bool> askStorage() async {
  final status = await Permission.storage.request();
  if (status == PermissionStatus.granted) return true;

  return false;
}
