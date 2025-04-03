
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
class Utility {

static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // setState(() {
   print( androidInfo.id); // Unique Android ID
      return  androidInfo.id;
      // });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
return iosInfo.identifierForVendor ?? "Unknown";
        // deviceId = iosInfo.identifierForVendor ?? "Unknown"; // Unique iOS ID
     
    }
    return "";
  }
}
