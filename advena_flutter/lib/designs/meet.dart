import 'package:advena_flutter/controllers/meet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                children: snapshot.data!.docs.map<Widget>((doc) {
                  var docData = doc.data() as Map<String, dynamic>;
                  return Text(
                    docData['name'],
                    style: TextStyle(
                        fontFamily: "WorkSans",
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  );
                  // return ListTile(
                  //   title: Text(docData['name'] ?? 'Unnamed Meetup'),
                  //   subtitle: Text(docData['description'] ?? 'No description'),
                  // );
                }).toList(),
              );
            },
          );
        }
      },
    );
  }
}
