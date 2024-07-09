import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

// ignore: must_be_immutable
class InterestsSelection extends StatefulWidget {
  List<String> selectedInterests = [];
  InterestsSelection({Key? key, required this.selectedInterests})
      : super(key: key);

  @override
  _InterestsSelectionState createState() => _InterestsSelectionState();
}

class _InterestsSelectionState extends State<InterestsSelection> {
  List<String> interests = [
    "Music",
    "Travel",
    "Sports",
    "Fitness and Wellness",
    "Food and Dining",
    "Movies and TV Shows",
    "Books and Reading",
    "Technology and Gadgets",
    "Art and Museums",
    "Theater and Performing Arts",
    "Outdoor Activities",
    "Gaming",
    "Shopping",
    "Photography",
    "Cooking and Baking",
    "DIY and Crafting",
    "Nightlife",
    "Volunteer Work",
    "Fashion and Style",
    "Pets and Animals",
  ];

  void toggleSelection(String interest) {
    setState(() {
      if (widget.selectedInterests.contains(interest)) {
        widget.selectedInterests.remove(interest);
      } else {
        widget.selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: interests.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 3,
        ),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final interest = interests[index];
          return InterestPill(
            interest: interest,
            isSelected: widget.selectedInterests.contains(interest),
            onTap: () => toggleSelection(interest),
          );
        },
      ),
    );
  }
}

class InterestPill extends StatelessWidget {
  final String interest;
  final bool isSelected;
  final VoidCallback onTap;

  InterestPill({
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? HexColor("#6100FF") : HexColor("#D3B8FF"),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? HexColor("#6100FF") : HexColor("#D3B8FF"),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Center(
          child: Text(
            interest,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: "WorkSans",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendationWidgets {
  List<String> userInterests = [];

  Widget recommendationOption(BuildContext context, bool isDay) {
    final Color textColor = isDay ? Colors.black : Colors.white;
    //TextEditingController interestsController = TextEditingController();

    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Let's gather some details about yourself, before we can generate some recommendations.",
              style: TextStyle(
                  fontFamily: "WorkSans", fontSize: 15, color: textColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Container(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await showRecommendationList(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontSize: 15,
                            color: HexColor('#FFFFFF')),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('#6100FF'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showRecommendationList(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Interests",
                    style: TextStyle(
                        fontFamily: "WorkSans",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Please select interests that suit you",
                      style: TextStyle(
                          fontFamily: "WorkSans", fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      InterestsSelection(
                        selectedInterests: userInterests,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print(userInterests);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                                fontFamily: 'WorkSans',
                                fontSize: 15,
                                color: HexColor('#FFFFFF')),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor('#6100FF'),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
