import 'dart:async';

import 'package:bus/api.dart';
import 'package:bus/get_id.dart';
import 'package:bus/utility.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:toastification/toastification.dart';

import './my_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensure Flutter is initialized
  await background_service.local_dataBase();
  // await background_service
  //     .requestPermissions(); // ✅ Ensure notification permission
  // await api.get_permission();
  // await background_service
  //     .initializeService(); // ✅ Initialize background service properly
  var a = background_service.prefs.getString("id");
  runApp(a != null && a != "-1" ? MyApp() : get_id());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterBackgroundService _service = FlutterBackgroundService();
  @override
  bool is_start = false;
  bool isConnected = false;
  bool loader = false;
  String? Divice_Id;

  void initState() {
    // TODO: implement initState
    super.initState();
    loader = true;
    checkInternet().then((value) {
      if (isConnected == true) {
        Utility.getDeviceId().then((value) async {
          Divice_Id = value;

          await _checkServiceStatus();
          background_service.requestPermissions().then((value) {
            api.get_permission().then((value) {
              background_service.initializeService().then((value) {
                setState(() {
                  loader = false;
                });
              });
            });
          });
          // ✅ Initialize background service properly
        });
      } else {
        setState(() {});
      }
    });

    // Timer.periodic(Duration(seconds: 2), (timer) async {
    //   // print("Background Service Running...");
    //   setState(() {});
    // });
  }

  Future<void> _checkServiceStatus() async {
    bool running = await _service.isRunning();
    setState(() {
      is_start = running;
    });
  }

  // Initial check
  Future<void> checkInternet() async {
    bool hasInternet =
        await InternetConnectionChecker.createInstance().hasConnection;
    if (hasInternet) {
      setState(() {
        isConnected = hasInternet;
        loader = false;
      });
      return;
    } else {
      _service.invoke("stopService");
      setState(() {
        isConnected = hasInternet;
        loader = false;
      });
      checkInternet();
    }
  }

  // Listen for network changes
  // void listenInternetChanges() {
  //   Connectivity().onConnectivityChanged.listen();
  // }
  // Future<void> checkInternet() async {
  //     var connectivityResult = await Connectivity().checkConnectivity();
  //     setState(() {
  //       isConnected = connectivityResult != ConnectivityResult.none;

  //       // setState(() {

  //       // });
  //     });
  //   }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(Divice_Id ?? ""),
          actions: [
            OutlinedButton.icon(
              onPressed: () async {
                _service.invoke("stopService");
                await background_service.prefs.setString("id", "-1");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => get_id()),
                );
              },
              label: Text("log out"),
            ),
          ],
        ),
        body:
            loader
                ? CircularProgressIndicator()
                : isConnected
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GestureDetector(
                        onTap: () async {
                          int contain_epo =
                              DateTime.now().millisecondsSinceEpoch;
                          await background_service.prefs.setInt(
                            'epoch',
                            contain_epo,
                          );
                          await background_service.prefs.setBool(
                            'service',
                            !is_start,
                          );
                          setState(() {
                            is_start = !is_start;
                            if (is_start) {
                              print(background_service.prefs.getInt("epoch"));
                              _service.startService();
                              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service Start")));
                            } else {
                              _service.invoke("stopService");
                              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service off")));
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child:
                              is_start
                                  ? Lottie.asset(
                                    'assets/lottie files/stop.json',
                                  )
                                  : Lottie.asset('assets/lottie files/go.json'),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _service.startService();
                    //     setState(() {});
                    //   },
                    //   child: Text("Start"),
                    // ),
                    // Center(child: Text('Running...')),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _service.invoke("stopService");
                    //     setState(() {});
                    //   },
                    //   child: Text("Stop"),
                    // ),
                  ],
                )
                : LottieBuilder.asset("assets/lottie files/no internet.json"),
      ),
    );
  }
}
