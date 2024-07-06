import 'dart:io';
import 'package:advena_flutter/controllers/home.dart';
import 'package:advena_flutter/designs/home.dart';
import 'package:advena_flutter/designs/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  User? user;
  Home({Key? key, this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeController _homeController = HomeController();
  Widgets _widgets = Widgets();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  XFile? profileImage;
  String? greeting;
  bool? isDay;
  bool isSubmitting = false;
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${greeting} ${widget.user?.displayName ?? 'Guest'}",
                style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: HexColor('#FFFFFF')),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontFamily: 'WorkSans'),
                ),
              ),
            ],
          ),
          if (widget.user?.displayName == null)
            AlertDialog(
              title: const Text(
                'Welcome to Advena!',
                style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Before you get started, we just we need a few details from your end.",
                    style: TextStyle(fontFamily: 'WorkSans'),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextField(
                        controller: displayNameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Your Name",
                            labelStyle: TextStyle(fontFamily: 'WorkSans')),
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: TextField(
                        controller: dobController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Date of Birth (DD/MM/YYYY)",
                            labelStyle: TextStyle(fontFamily: 'WorkSans')),
                      )),
                  profileImage != null
                      ? Center(
                          child: Image.file(File(profileImage!.path),
                              width: 200, height: 200),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _homeController.pickImage((image) {
                          setState(() {
                            profileImage = image;
                          });
                        });
                      },
                      child: const Text('Upload a profile photo',
                          style: TextStyle(
                              fontFamily: 'WorkSans',
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSubmitting = true;
                    });
                    _homeController.updateDisplayName(
                        displayNameController.text,
                        dobController.text,
                        profileImage, (user) {
                      setState(() {
                        isSubmitting = false;
                        widget.user = user;
                      });
                    });
                  },
                  child: isSubmitting
                      ? CircularProgressIndicator()
                      : Text(
                          'Submit',
                          style: TextStyle(
                              fontFamily: 'WorkSans',
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          if (widget.user?.displayName != null)
            SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                  child: _widgets.cityCountryWidget(isDay!),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                  child: _widgets.eventsWidget(),
                ),
              ],
            )),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          isDay!
              ? MorningGradientBackground(child: commonContent)
              : EveningGradientBackground(child: commonContent),
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
                                ? HexColor("#6100FF")
                                : Colors.blueGrey)),
                    InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        child: navbarItems(
                            Icon(Icons.search),
                            "Search",
                            _selectedIndex == 1
                                ? HexColor("#6100FF")
                                : Colors.blueGrey)),
                    InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                        child: navbarItems(
                            Icon(Icons.person),
                            "Account",
                            _selectedIndex == 2
                                ? HexColor("#6100FF")
                                : Colors.blueGrey)),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
