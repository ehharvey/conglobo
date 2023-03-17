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
  final _formKey = GlobalKey<FormState>();
  var _USBpath;
  bool error = false;
  bool installationComplete = false;

  void _startSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _progressValue = 0.0;
      installationComplete = false;
      error = false;
    });

    // Start the timer to increment the progress bar
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.2;
        } else if (_progressValue > 0.9) {
          setState(() {
            installationComplete = true;
          });
        } else {
          // Stop the timer when the setup is complete
          _timer?.cancel();
        }
      });
    });
    if (isUbuntu) {
      final file1 = File('$_USBpath/user-data.txt');
      final file2 = File('$_USBpath/meta-data.txt');
      final String secretFolderPath = '$_USBpath/secret';
      await Directory(secretFolderPath).create(recursive: true);
      final secret = File('$secretFolderPath/secret.txt');
      await secret.writeAsString(_tailScaleKey!);
      print('File created');
    } else {
      setState(() {
        error = true;
      });
    }
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 17),
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
                                  TextFormField(
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
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Please enter your NetMaker key',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      // Do something with the value entered in the text field
                                    },
                                  ),
                                ],
                              )
                            : Form(
                                key: _formKey,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Please enter your TailScale key',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your TailScale key';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    // Do something with the value entered in the text field
                                    if (value != '') {
                                      _tailScaleKey = value;
                                    }
                                  },
                                ),
                              )
                      ]),
                ),
              ),
            ),
            Container(
              height: 150,
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.only(left: 17.0, top: 15),
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
                                      if (bname.startsWith('example') &&
                                          ext == '.jsx') {
                                        setState(() {
                                          _USBpath = path;
                                          isUbuntu = true;
                                        });
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
            ),
            if (error)
              const Text(
                'Error, please check your USB folder',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(
              height: 17,
            ),
            !installationComplete
                ? SizedBox(
                    height: 10,
                    width: 700,
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : const Text(
                    "Installation completed sucessfully!",
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
            const SizedBox(
              height: 20,
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
          ],
        ),
      ),
    );
  }
}
