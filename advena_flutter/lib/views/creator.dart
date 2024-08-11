import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Creator extends StatefulWidget {
  final String userId;
  final bool isDay;
  const Creator({super.key, required this.userId, required this.isDay});

  @override
  State<Creator> createState() => _CreatorState();
}

class _CreatorState extends State<Creator> {
  late Color textColor;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<DocumentSnapshot> retrieveUser() {
    return _firestore.collection('appusers').doc(widget.userId).snapshots();
  }

  @override
  void initState() {
    super.initState();
    textColor = widget.isDay ? Colors.black : Colors.white;
    print(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: retrieveUser(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong',
                style: TextStyle(color: textColor));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading...",
                style: TextStyle(
                    color: textColor,
                    fontFamily: "WorkSans",
                    fontSize: 18,
                    fontWeight: FontWeight.bold));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('User profile has been deleted or does not exist.',
                style: TextStyle(
                    color: textColor,
                    fontFamily: "WorkSans",
                    fontSize: 18,
                    fontWeight: FontWeight.bold));
          }

          Map<String, dynamic> data =
              snapshot.data!.data()! as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("User Profile",
                    style: TextStyle(
                        color: textColor,
                        fontFamily: "WorkSans",
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.25,
                        decoration:
                            BoxDecoration(// Optional border for visibility
                                ),
                        child: Image.network(
                          data["profileImage"],
                          fit: BoxFit
                              .cover, // Ensures the image covers the entire box
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Text('Failed to load image'));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(data["username"],
                            style: TextStyle(
                                color: textColor,
                                fontFamily: "WorkSans",
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
