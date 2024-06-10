import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'views/login.dart';

void main() {
  runApp(const MainScreen());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: SafeArea(child: Padding(
          padding: EdgeInsets.all(10),
          child: Login()))),
      );
  }
}