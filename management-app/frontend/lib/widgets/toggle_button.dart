import 'package:conglobo_app/api/api.dart';
import 'package:flutter/material.dart';

import '../model/services.dart';

class MyToggleButton extends StatefulWidget {
  final String chosenService;
  const MyToggleButton({Key? key, required this.chosenService})
      : super(key: key);

  @override
  _MyToggleButtonState createState() => _MyToggleButtonState();
}

class _MyToggleButtonState extends State<MyToggleButton> {
  bool _isOn = true;
  Services _serviceStatuses = Services(services: {});

  @override
  Widget build(BuildContext context) {
    final String serviceName = widget.chosenService;
    return FutureBuilder<Services>(
      future: getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _serviceStatuses = snapshot.data!;
          final bool serviceStatus =
              _serviceStatuses.services[serviceName]?.status ?? false;
          _isOn = serviceStatus;
          return Container(
            height: 50,
            child: ToggleButtons(
              isSelected: <bool>[
                _isOn,
                !_isOn,
              ],
              onPressed: (int index) async {
                await toggleServiceStatus(
                    serviceName: serviceName, serviceStatus: _isOn);
                setState(() {
                  _isOn = !_isOn;
                });
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
