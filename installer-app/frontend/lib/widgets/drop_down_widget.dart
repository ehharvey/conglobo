import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final List<String> options;
  final Function(String?) onChanged;

  const DropdownWidget({required this.options, required this.onChanged});

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? _selectionOption;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectionOption,
      onChanged: (newValue) {
        setState(() {
          _selectionOption = newValue;
        });
        widget.onChanged(newValue);
      },
      items: widget.options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }
}
