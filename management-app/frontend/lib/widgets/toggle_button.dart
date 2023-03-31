import 'package:conglobo_app/api/api.dart';
import 'package:flutter/material.dart';

import '../model/apps.dart';

class MyToggleButton extends StatefulWidget {
  final String chosenService;
  const MyToggleButton({Key? key, required this.chosenService})
      : super(key: key);

  @override
  _MyToggleButtonState createState() => _MyToggleButtonState();
}

class _MyToggleButtonState extends State<MyToggleButton> {
  bool _isOn = true;
  Apps _serviceStatuses = Apps(services: {});

  @override
  Widget build(BuildContext context) {
    final String serviceName = widget.chosenService;
    return FutureBuilder<Apps>(
      future: getApps(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _serviceStatuses = snapshot.data!;
          final bool serviceStatus =
              _serviceStatuses.services[serviceName]?.active ?? false;
          _isOn = serviceStatus;
          print(_isOn);
          return Container(
            height: 50,
            child: ToggleButtons(
              isSelected: <bool>[
                !_isOn,
                _isOn,
              ],
              onPressed: (int index) async {
                if (_isOn) {
                  await deactivateApp(appName: serviceName);
                  setState(() {
                    _isOn = false;
                  });
                } else {
                  await activateApp(appName: serviceName);
                  setState(() {
                    _isOn = true;
                  });
                }
              },
              fillColor: Colors.blue,
              selectedColor: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("DISABLE"),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("ENABLE"),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
