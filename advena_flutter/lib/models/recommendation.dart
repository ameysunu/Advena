class SocialPreferences {
  String? dining;
  int? groupSize;
  String? socializing;

  SocialPreferences({this.dining, this.groupSize, this.socializing});

  factory SocialPreferences.fromJson(Map<String, dynamic> json) {
    return SocialPreferences(
      dining: json['dining'],
      groupSize: json['groupSize'],
      socializing: json['socializing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dining': dining,
      'groupSize': groupSize,
      'socializing': socializing,
    };
  }
}
