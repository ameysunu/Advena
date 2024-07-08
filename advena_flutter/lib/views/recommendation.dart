import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';

// ignore: must_be_immutable
class RecommendationView extends StatefulWidget {
  User? user;
  RecommendationView({Key? key, this.user});

  @override
  State<RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<RecommendationView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            "Recommendation",
            style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: HexColor('#FFFFFF')),
          ),
        ],
      ),
    );
  }
}
