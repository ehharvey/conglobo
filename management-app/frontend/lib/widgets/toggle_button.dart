import 'package:flutter/material.dart';

class MyToggleButton extends StatefulWidget {
  const MyToggleButton({Key? key}) : super(key: key);

  @override
  _MyToggleButtonState createState() => _MyToggleButtonState();
}

class _MyToggleButtonState extends State<MyToggleButton> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: <bool>[
        _isOn,
        !_isOn,
      ],
      onPressed: (int index) {
        setState(() {
          _isOn = !_isOn;
        });
      },
      fillColor: Colors.blue,
      selectedColor: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      children: const <Widget>[
        Text("OFF"),
        Text("ON"),
      ],
    );
  }
}
