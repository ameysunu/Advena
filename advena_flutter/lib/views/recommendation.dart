import 'package:advena_flutter/controllers/recommendation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';

// ignore: must_be_immutable
class RecommendationView extends StatefulWidget {
  User? user;
  bool isDay;

  RecommendationView({Key? key, this.user, required this.isDay});

  @override
  State<RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<RecommendationView> {
  RecommendationController _recommendationController =
      RecommendationController();
  late Future<bool> recommendationItems;
  late Color textColor;

  @override
  void initState() {
    super.initState();
    textColor = widget.isDay ? Colors.black : Colors.white;
    recommendationItems = _recommendationController.onLoadRecommendation();
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommendation",
            style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: HexColor('#FFFFFF')),
          ),
          FutureBuilder<bool>(
            future: recommendationItems,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                bool isTrue = snapshot.data ?? false;
                return Text(isTrue
                    ? 'Show Recommendations'
                    : 'Show screen asking for recommendation');
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
