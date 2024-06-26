import 'dart:async';
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

        for (int i = 0; i < 10; i++) {
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

  Widget cityCountryWidget() {
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
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              final eventResult = eventsList[index];
              if (eventResult.error != null) {
                final errorDetail = eventResult.error!.errors!.isEmpty
                    ? 'Unknown error'
                    : eventResult.error!.errors![0].detail!;
                return ListTile(
                  title: Text('Error: $errorDetail'),
                );
              } else {
                final events = eventResult.data!.embedded!.events!;
                return ListTile(
                  title: Text(events.isNotEmpty
                      ? events[0].name ?? 'No name'
                      : 'No events found'),
                );
              }
            },
          ),
        );
      },
    );
  }
}
