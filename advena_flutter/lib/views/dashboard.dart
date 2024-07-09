import 'dart:io';

import 'package:advena_flutter/controllers/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

import '../designs/widgets.dart';

// ignore: must_be_immutable
class DashboardView extends StatefulWidget {
  User? user;
  DashboardView({Key? key, this.user});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  
  HomeController _homeController = HomeController();
  Widgets _widgets = Widgets();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  XFile? profileImage;
  String? greeting;
  bool? isDay;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final greetingData = _homeController.getGreetingMessage();
    greeting = greetingData[0];
    isDay = greetingData[1];
  }

  Widget build(BuildContext context) {
    return Padding(
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

  }
}