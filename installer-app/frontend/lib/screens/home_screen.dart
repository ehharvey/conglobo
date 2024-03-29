import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/functions/function.dart';
import 'package:disks_desktop/disks_desktop.dart';
import 'package:frontend/widgets/drop_down_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedVpn;
  bool _isNetMaker = false;
  String? _tailScaleKey;
  TextEditingController _tailScaleKeyController = TextEditingController();
  double _progressValue = 0.0;
  Timer? _timer;
  final _formKey = GlobalKey<FormState>();
  String? _USBpath = 'Path not chosen';
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

    final String secretFolderPath = '$_USBpath/secret';
    final String noClourPath = '$_USBpath/nocloud';
    await Directory(secretFolderPath).create(recursive: true);
    await Directory(noClourPath).create(recursive: true);
    final secret = File('$secretFolderPath/secret.txt');
    await secret.writeAsString(_tailScaleKey!);
    final userData = File('$noClourPath/user-data');
    final metaData = File('$noClourPath/meta-data');
    await userData.create();
    await metaData.create();
    modifyGrub(_USBpath!);
    print('File created');
  }

  void _resetSetup() {
    setState(() {
      _progressValue = 0.0;
      installationComplete = false;
      error = false;
      _tailScaleKeyController.text = '';
      _timer?.cancel();
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
              height: 300,
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Card(
                color: const Color.fromARGB(255, 255, 244, 224),
                elevation: 10,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 17, right: 17),
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
                          hintText: 'Select VPN provider',
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
                                  controller: _tailScaleKeyController,
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
                color: const Color.fromARGB(255, 255, 244, 224),
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

                                  for (int i = 0; i < disks.length; i++) {
                                    if (disks[i].busType == "USB") {
                                      for (final mountPoint
                                          in disks[i].mountpoints) {
                                        final dir = Directory(mountPoint.path);
                                        print(dir);
                                        //final files = await dir.list().toList();
                                      }
                                      print(disks[i].description);
                                    }
                                  }

                                  String? selectedDirectory = await FilePicker
                                      .platform
                                      .getDirectoryPath();

                                  if (selectedDirectory == null) {
                                    // User canceled the picker
                                  } else {
                                    //print(selectedDirectory);
                                    var path = selectedDirectory;
                                    setState(() {
                                      _USBpath = path;
                                    });
                                    final dir = Directory(path);
                                    final files = await dir.list().toList();
                                  }
                                },
                                child: const Text("Select USB driver")),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Chosen USB: $_USBpath",
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
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 33, 107, 37)),
                    ),
                  )
                : const Text(
                    "Installation completed sucessfully!",
                    style: TextStyle(
                        color: Color.fromARGB(255, 33, 107, 37), fontSize: 20),
                  ),
            const SizedBox(
              height: 20,
            ),
            !installationComplete
                ? ElevatedButton(
                    onPressed: () {
                      _startSetup();
                    },
                    child: const Text("BEGIN INSTALLATION"),
                  )
                : ElevatedButton(
                    onPressed: () {
                      _resetSetup();
                    },
                    child: const Text("DONE"),
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
