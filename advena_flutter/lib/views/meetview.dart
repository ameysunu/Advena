import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MeetView extends StatefulWidget {
  const MeetView({super.key});

  @override
  State<MeetView> createState() => _MeetViewState();
}

class _MeetViewState extends State<MeetView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            "Meetup",
            style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: HexColor('#FFFFFF')),
          )
        ],
      ),
    );
  }
}
