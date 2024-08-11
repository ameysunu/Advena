import 'package:advena_flutter/controllers/meet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MeetupWidget extends StatefulWidget {
  const MeetupWidget({super.key});

  @override
  State<MeetupWidget> createState() => _MeetupWidgetState();
}

class _MeetupWidgetState extends State<MeetupWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}

// ignore: must_be_immutable
class MeetupListWidget extends StatefulWidget {
  final bool isDay;
  User? user;

  MeetupListWidget({required this.isDay, this.user});

  @override
  _MeetupListWidgetState createState() => _MeetupListWidgetState();
}

class _MeetupListWidgetState extends State<MeetupListWidget> {
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MeetupController controller = MeetupController();
  late Future<List<String>?> interestsFuture;

  @override
  void initState() {
    super.initState();
    interestsFuture = controller.loadUserInterests(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.isDay ? Colors.black : Colors.white;

    return FutureBuilder<List<String>?>(
      future: interestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(
              "Loading interests...",
              style: TextStyle(
                color: textColor,
                fontFamily: "WorkSans",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Failed to load interests",
              style: TextStyle(color: textColor),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '✨ No interests found. Please update your preferences ✨',
              style: TextStyle(
                color: textColor,
                fontFamily: "WorkSans",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          return StreamBuilder<QuerySnapshot>(
            stream: controller.meetupLists(snapshot.data!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Something went wrong',
                    style: TextStyle(color: textColor),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(
                      color: textColor,
                      fontFamily: "WorkSans",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No meetups are available in your location :(',
                    style: TextStyle(
                      color: textColor,
                      fontFamily: "WorkSans",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map<Widget>((doc) {
                  var docData = doc.data() as Map<String, dynamic>;

                  return meetupView(context, docData['name'],
                      docData['location'], docData['date']);
                }).toList(),
              );
            },
          );
        }
      },
    );
  }
}

Widget meetupView(
    BuildContext context, String title, String location, String date) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.3,
    child: Row(children: [
      GestureDetector(
        onTap: () async {},
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 100,
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                HexColor("#d16ba5"),
                HexColor("#c777b9"),
                HexColor("#ba83ca"),
                HexColor("#aa8fd8"),
                HexColor("#9a9ae1"),
                HexColor("#8aa7ec"),
                HexColor("#79b3f4"),
                HexColor("#69bff8"),
                HexColor("#52cffe"),
                HexColor("#41dfff"),
                HexColor("#46eefa"),
                HexColor("#5ffbf1"),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "WorkSans",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Text(
                      "$location @ $date",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "WorkSans",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]),
  );
}
