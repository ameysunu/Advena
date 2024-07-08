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

  RecommendationController _recommendationController = RecommendationController();
  late Future<List<Map<String, dynamic>>> recommendationItems;
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
          Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: recommendationItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No recommendations available', style: TextStyle(color: textColor)));
                  } else {
                    // Data is available, display it
                    final items = snapshot.data!;
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item['title'] ?? 'No Title', style: TextStyle(color: textColor)),
                          subtitle: Text(item['description'] ?? 'No Description', style: TextStyle(color: textColor)),
                        );
                      },
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
