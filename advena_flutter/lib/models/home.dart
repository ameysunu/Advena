class EventApiResponse {
  final Embedded? embedded;

  EventApiResponse({this.embedded});

  factory EventApiResponse.fromJson(Map<String, dynamic> json) {
    return EventApiResponse(
      embedded: json['_embedded'] != null ? Embedded.fromJson(json['_embedded']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_embedded': embedded?.toJson(),
    };
  }
}

class Embedded {
  final List<Event>? events;

  Embedded({this.events});

  factory Embedded.fromJson(Map<String, dynamic> json) {
    return Embedded(
      events: json['events'] != null ? List<Event>.from(json['events'].map((x) => Event.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events?.map((x) => x.toJson()).toList(),
    };
  }
}

class Event {
  final String? name;
  final String? type;
  final String? id;
  final bool? test;
  final String? url;
  final String? locale;
  final List<ImageItem>? images;

  Event({this.name, this.type, this.id, this.test, this.url, this.locale, this.images});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      type: json['type'],
      id: json['id'],
      test: json['test'],
      url: json['url'],
      locale: json['locale'],
      images: json['images'] != null ? List<ImageItem>.from(json['images'].map((x) => ImageItem.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'id': id,
      'test': test,
      'url': url,
      'locale': locale,
      'images': images?.map((x) => x.toJson()).toList(), 
    };
  }
}


class Images {
  final List<ImageItem>? images;

  Images({this.images});

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      images: json['images'] != null ? List<ImageItem>.from(json['images'].map((x) => ImageItem.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images': images?.map((x) => x.toJson()).toList(),
    };
  }
}


class ImageItem {
  final String? ratio;
  final String? url;
  final int? width;
  final int? height;
  final bool? fallback;

  ImageItem({this.ratio, this.url, this.width, this.height, this.fallback});

    factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      ratio: json['name'],
      url: json['url'],
      width: json['width'],
      height: json['height'],
      fallback: json['fallback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratio' : ratio,
      'url' : url,
      'width' : width,
      'height' : height,
      'fallback' : fallback
    };
}
}

class EventApiErrorResponse {
  final List<ErrorDetail>? errors;

  EventApiErrorResponse({this.errors});

  factory EventApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return EventApiErrorResponse(
      errors: json['errors'] != null ? List<ErrorDetail>.from(json['errors'].map((x) => ErrorDetail.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errors': errors?.map((x) => x.toJson()).toList(),
    };
  }
}

class ErrorDetail {
  final String? code;
  final String? detail;
  final String? status;
  final Links? links;

  ErrorDetail({this.code, this.detail, this.status, this.links});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      code: json['code'],
      detail: json['detail'],
      status: json['status'],
      links: json['_links'] != null ? Links.fromJson(json['_links']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'detail': detail,
      'status': status,
      '_links': links?.toJson(),
    };
  }
}

class Links {
  final About? about;

  Links({this.about});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      about: json['about'] != null ? About.fromJson(json['about']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'about': about?.toJson(),
    };
  }
}

class About {
  final String? href;

  About({this.href});

  factory About.fromJson(Map<String, dynamic> json) {
    return About(
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'href': href,
    };
  }
}

class EventApiResult {
  final EventApiResponse? data;
  final EventApiErrorResponse? error;

  EventApiResult({this.data, this.error});
}
