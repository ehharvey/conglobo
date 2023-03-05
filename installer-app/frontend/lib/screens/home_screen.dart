import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_widgets.dart';
import 'package:frontend/widgets/drop_down_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedUbuntiVersion;
  String? _selectedVpn;
  bool _isNetMaker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conglobo Installer'),
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Card(
              elevation: 10,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Ubuntu version',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownWidget(
                      options: const ['Jammy', '22.04.2'],
                      onChanged: (selectedOption) {
                        setState(() {
                          _selectedUbuntiVersion = selectedOption;
                        });
                        print(_selectedUbuntiVersion);
                      },
                    ),
                  ]),
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Card(
              elevation: 10,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select your VPN',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownWidget(
                      options: const ['TailScale', 'NetMaker'],
                      onChanged: (selectedOption) {
                        setState(() {
                          _selectedVpn = selectedOption;
                          if (_selectedVpn == "NetMaker") {
                            _isNetMaker = true;
                          } else {
                            _isNetMaker = false;
                          }
                        });
                        print(_selectedVpn);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _isNetMaker
                        ? Column(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  labelText:
                                      'Please enter your NetMaker endpoint',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  // Do something with the value entered in the text field
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Please enter your NetMaker key',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  // Do something with the value entered in the text field
                                },
                              ),
                            ],
                          )
                        : TextField(
                            decoration: const InputDecoration(
                              labelText: 'Please enter your TailScale key',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // Do something with the value entered in the text field
                            },
                          )
                  ]),
            ),
          ),
          Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Card(
              elevation: 10,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insert USB and Select driver',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              final folderPath =
                                  await FilePicker.platform.getDirectoryPath();
                              print('Folder path: $folderPath');
                            },
                            child: const Text("Select USB driver")),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          'No USB detected',
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                  ]),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("BEGIN INSTALLATION"),
          ),
          const SizedBox(
            height: 20,
          ),
          const LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          )
        ],
      ),
    );
  }
}
