import 'package:advena_flutter/controllers/home.dart';
import 'package:advena_flutter/designs/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Home extends StatefulWidget {
  final User? user;
  Home({Key? key, this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeController _homeController = HomeController();
  String? greeting;
  bool? isDay;

  void initState() {
    super.initState();
    greeting = _homeController.getGreetingMessage()[0];
    isDay = _homeController.getGreetingMessage()[1];
  }

  @override
  Widget build(BuildContext context) {
    Widget commonContent = Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            "${greeting}, ${widget.user!.displayName}",
            style: TextStyle(
                fontFamily: 'NeueHaas-Medium',
                fontSize: 17,
                color: HexColor('#FFFFFF')),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    return Scaffold(
      body: isDay!
          ? MorningGradientBackground(child: commonContent)
          : EveningGradientBackground(child: commonContent),
    );
  }
}
