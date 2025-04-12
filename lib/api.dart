import 'dart:convert';
import 'dart:developer';

import 'package:bus/my_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class api {
  static Future<void> get_permission() async {
    bool serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      Geolocator.openLocationSettings();
      get_permission();
      return Future.error("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // loader(false);
        // snack_bar(context: context, message: "Location permissions are denied");
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permissions are denied")));
        // snack_bar2(
        //     context: context, message: " Location permissions are denied");
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "Location Permission are permanently denied, we cannot request",
      );
    }
  }

  static Future<Position> get_loc() async {
    bool serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      Geolocator.openLocationSettings();
      // Geolocator.openAppSettings();
      // Api.snack_bar(context: context, message: "turn on Location");

      // snack_bar2(context: context, message: "turn on Location");
      // loader(false);
      return Future.error("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // loader(false);
        // snack_bar(context: context, message: "Location permissions are denied");
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permissions are denied")));
        // snack_bar2(
        //     context: context, message: " Location permissions are denied");
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // loader(false);
      //  snack_bar(context: context, message: "Location Permission are permanently denied");
      //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location Permission are permanently denied")));
      // snack_bar2(
      //     context: context,
      //     message: "Location Permission are permanently denied");
      return Future.error(
        "Location Permission are permanently denied, we cannot request",
      );
    }
    //  loader(false);
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
      forceAndroidLocationManager: true,
    );
  }

  static Future<void> send_let_log({
    required String DriverId,
    required String lat,
    required String long,
    required String DeviceId,
    required String EpochId,
  }) async {
    var a = background_service.prefs.getString("id");
    String url =
        'https://schoolappapi.schoolsoftwaresolution.in/MobApi.asmx/MobileApi?ParmCriteria={"DriverId":"$a","DeviceId":"$DeviceId","Latitude":"$lat","Longitude":"$long","EpochId":"$EpochId","ApiAdd":"DriverLatitudeLongitude","CallBy":"MobileApi","AuthKey":"AK101"}&SchID=VSS&ApiAdd=DriverLatitudeLongitude';
    var res = await http.get(Uri.parse(url));
    Map<String, dynamic> data;
    print(url);
    if (res.statusCode == 200) {
      data = jsonDecode(res.body);
      log("send_let_log Api call.... ");
      // return data;
    } else {
      log("Error........ send_let_log Api ");
    }
  }
}
