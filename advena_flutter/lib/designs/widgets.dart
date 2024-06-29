import 'dart:async';
import 'dart:math';
import 'package:advena_flutter/controllers/geohash.dart';
import 'package:advena_flutter/controllers/home.dart';
import 'package:advena_flutter/models/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class Widgets {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final GeoHash geoHashClass = GeoHash();
  final loc.Location location = loc.Location();
  final HomeController _homeController = HomeController();

  final StreamController<LatLng?> _locationStreamController =
      StreamController<LatLng?>();
  final StreamController<String> _cityCountryStreamController =
      StreamController<String>();
  final StreamController<List<EventApiResult>?> _eventsStreamController =
      StreamController<List<EventApiResult>?>.broadcast();

  Widgets() {
    _fetchLocationAndCityCountry();
  }

  Future<void> _fetchLocationAndCityCountry() async {
    try {
      LatLng? userLocation = await _getCurrentLocation();
      if (userLocation != null) {
        _locationStreamController.add(userLocation);

        String cityCountry = await _getCityCountry(userLocation);
        _cityCountryStreamController.add(cityCountry);

        var geoPoint = GeoPoint(userLocation.latitude, userLocation.longitude);
        var geoHash = geoHashClass
            .encodeGeohash(geoPoint.latitude, geoPoint.longitude, precision: 9);

        List<EventApiResult> eventsList = [];

        var random = Random();
        List<int> randomNumbers = List.generate(5, (_) => random.nextInt(250));

        for (var i in randomNumbers) {
          EventApiResult? events =
              await _homeController.getEventsFromTicketMaster(geoHash, "$i");
          eventsList.add(events);
        }

        _eventsStreamController.add(eventsList);
      } else {
        _cityCountryStreamController.add('Unknown location');
        _eventsStreamController.add(null);
      }
    } catch (e) {
      _cityCountryStreamController.add('Error: $e');
    }
  }

  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return null;
      }
    }

    final locData = await location.getLocation();
    return LatLng(locData.latitude ?? 0.0, locData.longitude ?? 0.0);
  }

  Future<String> _getCityCountry(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.administrativeArea ?? '';
        String country = place.country ?? '';
        return '$city, $country';
      } else {
        return 'Unknown location';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Widget mapWidget() {
    return StreamBuilder<LatLng?>(
      stream: _locationStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Could not get location.'));
        }

        final userLocation = snapshot.data!;
        final CameraPosition initialCameraPosition = CameraPosition(
          target: userLocation,
          zoom: 14.4746,
        );

        return Container(
          height: 300,
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(initialCameraPosition));
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        );
      },
    );
  }

  Widget cityCountryWidget(bool isDay) {
    final Color textColor = isDay ? Colors.black : Colors.white;

    return StreamBuilder<String>(
      stream: _cityCountryStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.contains('Error')) {
          return Center(child: Text('Could not get location.'));
        }

        return Text(
          "What's happening in \n${snapshot.data!}",
          style: TextStyle(
            fontFamily: "WorkSans",
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: textColor,
          ),
        );
      },
    );
  }

  Widget eventsWidget() {
    return StreamBuilder<List<EventApiResult>?>(
      stream: _eventsStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Could not get events.'));
        }

        final eventsList = snapshot.data!;

        if (eventsList.isEmpty) {
          return Center(child: Text('No events found.'));
        }

        return Container(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              final eventResult = eventsList[index];
              if (eventResult.error != null) {
                final errorDetail = eventResult.error!.errors!.isEmpty
                    ? 'Unknown error'
                    : eventResult.error!.errors![0].detail!;
                return Container(
                  width: 200,
                  child: Center(
                    child: Text('Error: $errorDetail'),
                  ),
                );
              } else {
                final events = eventResult.data!.embedded!.events!;
                return Row(
                  children: events.map((event) {
                    return GestureDetector(
                      onTap: () async {
                        // if (event.url != null) {
                        //   if (await canLaunch(event.url!)) {
                        //     await launch(event.url!);
                        //   } else {
                        //     throw 'Could not launch ${event.url}';
                        //   }
                        // }
                        await showDialogWidget(context, event);
                      },
                      child: Container(
                        width: 300,
                        height: 300,
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(
                              event.images![0].url!,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Spacer(),
                                Text(
                                  event.name ?? 'No name',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "WorkSans",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Text(
                                    "${_homeController.formatEventDate(event.dates!.start!.localDate!)} @ ${event.dates?.start?.localTime}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "WorkSans",
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> showDialogWidget(BuildContext context, Event event) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      event.name ?? 'No name',
                      style: TextStyle(
                          fontFamily: "WorkSans",
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 10),
                    child: Text(
                        "${event.embedded!.venues![0].name}, ${event.embedded!.venues![0].address!.line1}, ${event.embedded!.venues![0].address!.line2}",
                        style: TextStyle(
                          fontFamily: "WorkSans",
                          fontSize: 20,
                        )),
                  ),
                  venueMapWidget(
                      event.embedded!.venues![0].location!.longitude!,
                      event.embedded!.venues![0].location!.latitude!,
                      context),
                  ElevatedButton(
                    child: Text('Close BottomSheet'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget venueMapWidget(
      String longitude, String latitude, BuildContext context) {
    final double lat = double.parse(latitude);
    final double lng = double.parse(longitude);
    final LatLng location = LatLng(lat, lng);
    // ignore: unused_local_variable
    late GoogleMapController _controller;

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('location_marker'),
            position: location,
          ),
        },
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }
}
