import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_widgets.dart';
import 'package:disks_desktop/disks_desktop.dart';
import 'package:frontend/widgets/drop_down_widget.dart';
import 'package:path/path.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedUbuntiVersion;
  String? _selectedVpn;
  bool _isNetMaker = false;
  String? _tailScaleKey;
  double _progressValue = 0.0;
  Timer? _timer;
  bool isUbuntu = false;

  void _startSetup() {
    setState(() {
      _progressValue = 0.0;
    });

    // Start the timer to increment the progress bar
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.5;
        } else {
          // Stop the timer when the setup is complete
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conglobo Installer'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                                if (value != '') {
                                  _tailScaleKey = value;
                                }
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
                        'Insert USB and select the USB folder',
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
                                final repository = DisksRepository();
                                final disks = await repository.query;
                                print(disks[1].devicePath);
                                String? selectedDirectory = await FilePicker
                                    .platform
                                    .getDirectoryPath();

                                if (selectedDirectory == null) {
                                  // User canceled the picker
                                } else {
                                  //print(selectedDirectory);
                                  var path = selectedDirectory;
                                  final dir = Directory(path);
                                  final files = await dir.list().toList();
                                  for (final file in files) {
                                    final bname = basename(file.path);
                                    final ext = extension(bname);
                                    if (bname.startsWith('ubuntu') &&
                                        ext == '.iso') {
                                      final file1 = File('$path/user-data.txt');
                                      final file2 = File('$path/meta-data.txt');
                                      await file1.writeAsString(_tailScaleKey!);
                                      print('File created');
                                    }
                                  }
                                }
                              },
                              child: const Text("Select USB driver")),
                          const SizedBox(
                            width: 20,
                          ),
                          !isUbuntu
                              ? const Text(
                                  'USB folder with ubutu installed not found!',
                                  style: TextStyle(color: Colors.red),
                                )
                              : const Text(
                                  'Ubuntu installer found',
                                  style: TextStyle(color: Colors.green),
                                )
                        ],
                      ),
                    ]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _startSetup();
              },
              child: const Text("BEGIN INSTALLATION"),
            ),
            const SizedBox(
              height: 20,
            ),
            LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            )
          ],
        ),
      ),
    );
  }
}
