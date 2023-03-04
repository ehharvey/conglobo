import 'package:conglobo_app/screens/home_screen.dart';
import 'package:conglobo_app/screens/settings_screen.dart';
import 'package:conglobo_app/screens/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conglobo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PageSelector(),
    );
  }
}

class PageSelector extends StatefulWidget {
  const PageSelector({super.key});

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  int currentPage = 0;
  List<Widget> pages = const [HomeScreen(), SetupScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conglobo'),
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Color.fromARGB(255, 238, 243, 255),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'Conglobo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.screenshot_monitor),
                label: Text('Setup'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: currentPage,
            onDestinationSelected: (int index) {
              setState(() {
                currentPage = index;
              });
            },
          ),
          Expanded(
            child: pages[currentPage],
          ),
        ],
      ),
    );
  }
}

/*
class PageSelector extends StatefulWidget {
  const PageSelector({super.key});

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  int currentPage = 0;
  List<Widget> pages = const [HomeScreen(), SetupScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conglobo'),
      ),
      body: pages[currentPage],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 58, 121, 255),
          boxShadow: [
            BoxShadow(
              blurRadius: 50,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: GNav(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              rippleColor: Color.fromARGB(255, 0, 246, 254),
              hoverColor: Color.fromARGB(255, 185, 185, 185),
              gap: 8,
              activeColor: Color.fromARGB(255, 21, 208, 255),
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Color.fromARGB(255, 255, 255, 255),
              tabBorder:
                  Border.all(color: Color.fromARGB(255, 67, 67, 67), width: 2),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.screenshot_monitor,
                  text: 'Setup',
                ),
                GButton(
                  icon: Icons.settings,
                  text: 'Settings',
                ),
              ],
              onTabChange: (int index) {
                setState(() {
                  currentPage = index;
                });
              },
              selectedIndex: currentPage,
            ),
          ),
        ),
      ),
    );
  }
}
*/