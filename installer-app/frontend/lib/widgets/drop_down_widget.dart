import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final List<String> options;
  final Function(String?) onChanged;
  final String hintText;

  const DropdownWidget(
      {required this.options, required this.onChanged, required this.hintText});

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? _selectionOption;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text(widget.hintText),
      value: _selectionOption == '' ? 'TailScale' : _selectionOption,
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
