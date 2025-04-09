import 'dart:async';
import 'dart:developer';

import 'package:bus/api.dart';
import 'package:bus/utility.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class background_service {
  static double lot = 0.0;
  static double let = 0.0;
  static late SharedPreferences prefs;
  static Future<void> local_dataBase() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(),
    );

    // service.invoke("stopService");
    bool? is_service = background_service.prefs.getBool("service");
    if (is_service != null && is_service == true) {
      service.startService();
    } else {
      // service.stopSelf();
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService(); // ✅ Prevents Android from stopping it
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'foreground_service', // unique ID
        'Foreground Service', // Name for users
        description: 'This is a foreground service',
        importance: Importance.high,
        playSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          icon:
              '@mipmap/ic_launcher', // Ensure you have an icon in res/drawable
        ),
      );

      // Initialize local notifications
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Set foreground notification
      service.setForegroundNotificationInfo(
        title: "Bus App Running",
        content: "Tap to return to the app",
      );

      // Show notification to avoid Android 13 crash
      flutterLocalNotificationsPlugin.show(
        1,
        'Bus App Running',
        'Foreground service is active',
        notificationDetails,
      );
      prefs = await SharedPreferences.getInstance();
      // while(true){
      int a = 0;
      // }
      Timer.periodic(Duration(seconds: 1), (timer) async {
        print("Background Service Running...");
        await api.get_loc().then((value) async {
          print(prefs.get("epoch"));
          // if(lot!=value.longitude||let!=value.latitude){
          var res = calculateDistance(
            startLatitude: double.parse(value.latitude.toStringAsFixed(6)),
            startLongitude: double.parse(value.longitude.toStringAsFixed(6)),
            endLatitude: double.parse(let.toStringAsFixed(6)),
            endLongitude: double.parse(lot.toStringAsFixed(6)),
          );
          print(res);
          print(
            "longitude= " +
                value.longitude.toStringAsFixed(6) +
                " " +
                "latitude= " +
                value.latitude.toStringAsFixed(6),
          );
          // if (res >= 0.55) {
          print("${++a}");
          lot = double.parse(value.longitude.toStringAsFixed(6));
          let = double.parse(value.latitude.toStringAsFixed(6));
          print("lot= " + lot.toString() + " " + "let= " + let.toString());
          log("Api call.....");
          // await api.send_let_log(Divice_Id: "1", lat: let.toString(), long: lot.toString());
          String device_id = await Utility.getDeviceId();
          await api.send_let_log(
            DeviceId: device_id,
            DriverId: "1",
            EpochId: prefs.get("epoch").toString(),
            lat: let.toStringAsFixed(6),
            long: lot.toStringAsFixed(6),
          );
          // }
          // }
        });
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            service.setForegroundNotificationInfo(
              title: "hello",
              content: "jkjdkfjf",
            );
          }
        }
      });
    }
    service.on("stopService").listen((event) {
      service.stopSelf();
    });
  }

  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    double distance = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distance; // Convert meters to kilometers
    // return distance / 1000; // Convert meters to kilometers
  }
}
