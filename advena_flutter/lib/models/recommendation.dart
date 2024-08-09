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

class GeminiInterestsResponse {
  String? title;
  String? description;
  String? id;
  String? location;
  String? address;

  GeminiInterestsResponse(
      {this.title, this.description, this.id, this.location, this.address});

  factory GeminiInterestsResponse.fromJson(Map<String, dynamic> json) {
    return GeminiInterestsResponse(
        title: json['title'],
        description: json['description'],
        id: json['id'],
        location: json['location'],
        address: json['address']);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'id': id,
      'location': location,
      'address': address
    };
  }
}
