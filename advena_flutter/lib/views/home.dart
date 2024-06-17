import 'dart:io';
import 'package:advena_flutter/controllers/home.dart';
import 'package:advena_flutter/designs/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  final User? user;
  Home({Key? key, this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeController _homeController = HomeController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  XFile? profileImage;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${greeting} ${widget.user?.displayName ?? 'Guest'}",
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
          if (widget.user?.displayName == null)
            AlertDialog(
              title: const Text(
                'Welcome to Advena!',
                style: TextStyle(fontFamily: 'NeueHaas-Medium', fontSize: 25),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    " Before you get started, we just we need a few details from your end.",
                    style: TextStyle(fontFamily: 'NeueHaas-Light'),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextField(
                        controller: displayNameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Your Name",
                            labelStyle:
                                TextStyle(fontFamily: 'NeueHaas-Light')),
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: TextField(
                        controller: dobController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Date of Birth (DD/MM/YYYY)",
                            labelStyle:
                                TextStyle(fontFamily: 'NeueHaas-Light')),
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
                          style: TextStyle(fontFamily: 'NeueHaas-Medium')),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    print("GALANTIS");
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontFamily: 'NeueHaas-Medium'),
                  ),
                ),
              ],
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
