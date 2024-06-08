import 'package:flutter/material.dart';

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
        home: Scaffold(body: SafeArea(child: Text('Hi there! Welcome to Advena', style: TextStyle(fontFamily: 'NeueHaas-Medium', fontSize: 25),))),
      );
  }
}