import 'package:advena_flutter/designs/meet.dart';
import 'package:advena_flutter/designs/recommendation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../controllers/recommendation.dart';

// ignore: must_be_immutable
class MeetView extends StatefulWidget {
  User? user;
  bool isDay;

  MeetView({Key? key, this.user, required this.isDay});

  @override
  State<MeetView> createState() => _MeetViewState();
}

class _MeetViewState extends State<MeetView> {
  late RecommendationController _recommendationController;
  // ignore: unused_field
  late RecommendationWidgets _recommendationWidgets;
  late Stream<bool> recommendationItems;
  late Color textColor;

  @override
  void initState() {
    super.initState();
    _recommendationWidgets = RecommendationWidgets(widget.user!);
    _recommendationController = RecommendationController(widget.user);
    textColor = widget.isDay ? Colors.black : Colors.white;
    recommendationItems = _recommendationController.onLoadRecommendation();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Meetup",
            style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: HexColor('#FFFFFF')),
          ),
          StreamBuilder<bool>(
            stream: recommendationItems,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                bool isTrue = snapshot.data ?? false;
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isTrue
                          ? MeetupListWidget(
                              isDay: widget.isDay,
                              user: widget.user,
                            )
                          : _recommendationWidgets.recommendationOption(
                              context, widget.isDay),
                      SizedBox(height: 70),
                    ],
                  ),
                );
              } else {
                return Text('No data');
              }
            },
          ),
        ],
      ),
    );
  }
}
