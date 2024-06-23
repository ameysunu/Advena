import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Widgets {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  final Location location = Location();

  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

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
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    final locData = await location.getLocation();
    return LatLng(locData.latitude ?? 0.0, locData.longitude ?? 0.0);
  }

  Widget mapWidget() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder<LatLng?>(
        future: _getCurrentLocation(),
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
      ),
    );
  }
}
