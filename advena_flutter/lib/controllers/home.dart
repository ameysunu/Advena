class HomeController {
  List<dynamic> getGreetingMessage() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      return ['Good Morning', true];
    } else if (hour < 18) {
      return ['Good Afternoon', true];
    } else {
      return ['Good Evening', false];
    }
  }
}
