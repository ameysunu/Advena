import 'package:advena_flutter/controllers/home.dart';
import 'package:advena_flutter/designs/home.dart';
import 'package:advena_flutter/views/dashboard.dart';
import 'package:advena_flutter/views/meetview.dart';
import 'package:advena_flutter/views/recommendation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  User? user;
  Home({Key? key, this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeController _homeController = HomeController();
  String? greeting;
  bool? isDay;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final greetingData = _homeController.getGreetingMessage();
    greeting = greetingData[0];
    isDay = greetingData[1];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      DashboardView(
        user: widget.user,
      ),
      RecommendationView(
        user: widget.user,
        isDay: isDay!,
      ),
      MeetView(
        user: widget.user,
        isDay: isDay!,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          isDay!
              ? MorningGradientBackground(
                  child: IndexedStack(index: _selectedIndex, children: _pages))
              : EveningGradientBackground(
                  child: IndexedStack(index: _selectedIndex, children: _pages)),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
                elevation: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                        child: navbarItems(
                            Icon(Icons.dashboard),
                            "Dashboard",
                            _selectedIndex == 0
                                ? Colors.blueAccent
                                : Colors.blueGrey)),
                    InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        child: navbarItems(
                            Icon(Icons.card_membership_outlined),
                            "Recommendation",
                            _selectedIndex == 1
                                ? Colors.blueAccent
                                : Colors.blueGrey)),
                    InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                        child: navbarItems(
                            Icon(Icons.batch_prediction_rounded),
                            "Meetup",
                            _selectedIndex == 2
                                ? Colors.blueAccent
                                : Colors.blueGrey)),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
