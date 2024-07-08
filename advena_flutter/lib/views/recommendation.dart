import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

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
    return const Text("Recommendation");
  }
}
