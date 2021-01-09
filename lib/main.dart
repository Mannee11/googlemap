import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _homeloc = "searching...";
  Position _currentPosition;
  String gmaploc = "";
  CameraPosition _userpos;

  double latitude = 6.4676929;
  double longitude = 100.5067673;
  Set<Marker> markers = Set();
  MarkerId markerId1 = MarkerId("12");
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    try {
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.teal[100],
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.greenAccent,
            title: Text(
              "Google Maps",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  height: 340,
                  width: 340,
                  child: GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: _userpos,
                      markers: markers.toSet(),
                      onMapCreated: (controller) {
                        _controller.complete(controller);
                      },
                      onTap: (newLatLng) {
                        _loadLoc(newLatLng);
                      }),
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          child: Text("Latest Address :",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    _homeloc,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Text(
                    "Latest Latitude:",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: Text(
                    latitude.toString(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Text(
                    "Latest Longitude:",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: Text(
                    longitude.toString(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _loadLoc(LatLng loc) async {
    markers.clear();
    latitude = loc.latitude;
    longitude = loc.longitude;
    _getLocationfromlatlng(latitude, longitude);

    markers.add(Marker(
      markerId: markerId1,
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
          title:
              latitude.toStringAsFixed(7) + "/" + longitude.toStringAsFixed(7)),
    ));
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
  }

  _getLocationfromlatlng(double lat, double lng) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _homeloc = first.addressLine;

    setState(() {
      _homeloc = first.addressLine;
    });
  }

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        print(position);
        markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
            }
          });
        }
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}
