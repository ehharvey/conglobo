import 'package:conglobo_app/widgets/list_view.dart';
import 'package:conglobo_app/widgets/toggle_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Welcome to Conglobo',
              style: TextStyle(fontSize: 30),
            ),
            Expanded(child: MyListView())
          ],
        ),
      ),
    );
  }
}
