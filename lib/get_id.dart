import 'package:bus/api.dart';
import 'package:bus/main.dart';
import 'package:bus/my_service.dart';
import 'package:flutter/material.dart';

class get_id extends StatefulWidget {
  const get_id({super.key});

  @override
  State<get_id> createState() => _get_idState();
}

class _get_idState extends State<get_id> {
  var id_con = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextFormField(controller: id_con),
            OutlinedButton(
              onPressed: () async {
                if (id_con.text.isNotEmpty) {
                  await background_service.prefs.setString(
                    "id",
                    id_con.text.trim(),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                }
              },
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
