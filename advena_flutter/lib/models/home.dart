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
  final Dates? dates;

  Event({
    this.name,
    this.type,
    this.id,
    this.test,
    this.url,
    this.locale,
    this.images,
    this.dates,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      type: json['type'],
      id: json['id'],
      test: json['test'],
      url: json['url'],
      locale: json['locale'],
      images: json['images'] != null ? List<ImageItem>.from(json['images'].map((x) => ImageItem.fromJson(x))) : null,
      dates: json['dates'] != null ? Dates.fromJson(json['dates']) : null,
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
      'dates': dates?.toJson(),
    };
  }
}

class Dates {
  final Start? start;
  final String? timezone;
  final Status? status;
  final bool? spanMultipleDays;

  Dates({this.start, this.timezone, this.status, this.spanMultipleDays});

  factory Dates.fromJson(Map<String, dynamic> json) {
    return Dates(
      start: json['start'] != null ? Start.fromJson(json['start']) : null,
      timezone: json['timezone'],
      status: json['status'] != null ? Status.fromJson(json['status']) : null,
      spanMultipleDays: json['spanMultipleDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start?.toJson(),
      'timezone': timezone,
      'status': status?.toJson(),
      'spanMultipleDays': spanMultipleDays,
    };
  }
}

class Start {
  final String? localDate;
  final String? localTime;
  final String? dateTime;
  final bool? dateTBD;
  final bool? dateTBA;
  final bool? timeTBA;
  final bool? noSpecificTime;

  Start({
    this.localDate,
    this.localTime,
    this.dateTime,
    this.dateTBD,
    this.dateTBA,
    this.timeTBA,
    this.noSpecificTime,
  });

  factory Start.fromJson(Map<String, dynamic> json) {
    return Start(
      localDate: json['localDate'],
      localTime: json['localTime'],
      dateTime: json['dateTime'],
      dateTBD: json['dateTBD'],
      dateTBA: json['dateTBA'],
      timeTBA: json['timeTBA'],
      noSpecificTime: json['noSpecificTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localDate': localDate,
      'localTime': localTime,
      'dateTime': dateTime,
      'dateTBD': dateTBD,
      'dateTBA': dateTBA,
      'timeTBA': timeTBA,
      'noSpecificTime': noSpecificTime,
    };
  }
}

class Status {
  final String? code;

  Status({this.code});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
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
      ratio: json['ratio'],
      url: json['url'],
      width: json['width'],
      height: json['height'],
      fallback: json['fallback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratio': ratio,
      'url': url,
      'width': width,
      'height': height,
      'fallback': fallback,
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
