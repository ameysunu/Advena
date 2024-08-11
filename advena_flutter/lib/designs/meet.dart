import 'package:advena_flutter/controllers/meet.dart';
import 'package:advena_flutter/views/creator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

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

                  return meetupView(
                      context,
                      docData['name'],
                      docData['location'],
                      docData['date'],
                      docData['description'],
                      docData['attendees'],
                      docData['created']);
                }).toList(),
              );
            },
          );
        }
      },
    );
  }
}

Widget meetupView(BuildContext context, String title, String location,
    String date, String description, int attendees, String creator) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.3,
    child: Row(children: [
      GestureDetector(
        onTap: () async {
          await showMeetup(
              context, title, description, location, date, attendees, creator);
        },
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

Future<void> showMeetup(BuildContext context, String title, String description,
    String location, String date, int attendees, String creator) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: "WorkSans",
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 10),
                  child: Text("$description",
                      style: TextStyle(
                        fontFamily: "WorkSans",
                        fontSize: 20,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "$location",
                    style: TextStyle(
                        fontFamily: "WorkSans",
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "$date",
                    style: TextStyle(fontFamily: "WorkSans", fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Registered people: $attendees",
                    style: TextStyle(fontFamily: "WorkSans", fontSize: 20),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                  body: SafeArea(
                                      child: Creator(
                                          isDay: true, userId: creator))),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#FF693E'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        ),
                        child: Text(
                          'Meet the creator',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: "WorkSans"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#FF0071'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        ),
                        child: Text(
                          "Not for me",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: "WorkSans"),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.thumb_up, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#1000FF'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: "WorkSans"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
