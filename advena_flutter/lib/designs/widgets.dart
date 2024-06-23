import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class Widgets {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  final loc.Location location = loc.Location();

  final StreamController<LatLng?> _locationStreamController =
      StreamController<LatLng?>();
  final StreamController<String> _cityCountryStreamController =
      StreamController<String>();

  Widgets() {
    _fetchLocationAndCityCountry();
  }

  Future<void> _fetchLocationAndCityCountry() async {
    try {
      LatLng? userLocation = await _getCurrentLocation();
      _locationStreamController.add(userLocation);

      if (userLocation != null) {
        String cityCountry = await _getCityCountry(userLocation);
        _cityCountryStreamController.add(cityCountry);
      } else {
        _cityCountryStreamController.add('Unknown location');
      }
    } catch (e) {
      _cityCountryStreamController.add('Error: $e');
    }
  }

  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check for location permissions
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
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? '';
        String country = place.country ?? '';
        print(place);
        if (city == '') {
          city = place.administrativeArea ?? '';
        }
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

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Could not get location.'));
        }

        if (snapshot.data!.contains('Error')) {
          return Center(child: Text(""));
        }

        return Text(
          snapshot.data!,
          style: TextStyle(
              fontFamily: "WorkSans",
              fontWeight: FontWeight.bold,
              fontSize: 25),
        );
      },
    );
  }

  Widget combinedWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mapWidget(),
        SizedBox(height: 10),
        cityCountryWidget(),
      ],
    );
  }
}
