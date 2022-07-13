import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_controller/google_maps_controller.dart';
import 'package:location/location.dart';

import 'myzones.dart';

class TheLocation extends StatefulWidget {
  const TheLocation({Key? key}) : super(key: key);

  @override
  State<TheLocation> createState() => _TheLocationState();
}

class _TheLocationState extends State<TheLocation> {
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(32.594863539518116, 44.01412402294828),
    zoom: 14,
  );
  Location location = Location();
  LocationData? _locationData;
  String? _myZone;
  Set<Marker> markersSet = {};
  var ref = FirebaseDatabase.instance.ref().child("activeDrivers");
  var dList = [];
  String driverId = '';

  getPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<String> getZoneNameRealTime() async {
    String zone;
    Point? userPoint;
    try {
      _locationData = await location.getLocation();
      Point userPoint = Point(_locationData!.latitude as num, _locationData!.longitude as num);
      zone = MyZones().getZoneNameByPoint(userPoint);

      getMarker();
    } catch (e) {
      print(e);
    }
    /* location.onLocationChanged.listen((LocationData currentLocation) {
      _locationData = currentLocation;
      // Point userPoint = Point(_locationData!.latitude as num, _locationData!.longitude as num);
      // getMarker();
      //  zone = MyZones().getZoneNameByPoint(userPoint!);
      //  print('the zome is $zone');
    });*/
    zone = MyZones().getZoneNameByPoint(userPoint!);
    return zone;
  }

  getSortedDriver() async {
    var newMap;
    try {
      var firebaseDriversData = await ref.get();
      var mapOfFBData = firebaseDriversData.value as Map;

      newMap = Map.fromEntries(
        mapOfFBData.entries.toList()
          ..sort(
            (e1, e2) => DateTime.parse(e1.value["time"]!).compareTo(
              DateTime.parse(e2.value["time"]!),
            ),
          ),
      );
    } catch (e) {
      print('error is ${e.toString()}');
    }
    dList = [];
    newMap.forEach((key, value) {
      dList.add([key, value]);
    });
    // print(dList);
    dList.forEach((element) {
      // print('${element[0]} ${element[1]['time']} : ${element[1]['zone']}');
    });
    print('----------------------------');
    // print(dList.firstWhere((element) => element[1]['zone'] == _myZone)[0]);
    try {
      driverId = dList.firstWhere((element) => element[1]['zone'] == _myZone)[0];
    } catch (e) {
      print(e);
      driverId = 'No drivers in the zone';
    }

    print('the driverId is $driverId');
    setState(() {});
  }

  getLocation() async {
    try {
      _locationData = await location.getLocation();
      Point userPoint = Point(_locationData!.latitude as num, _locationData!.longitude as num);
      _myZone = MyZones().getZoneNameByPoint(userPoint);
      print('userZone $_myZone');
      getMarker();
      getSortedDriver();
    } catch (e) {
      // print(e);
    }
  }

  getMarker() {
    var cameraMarker = Marker(
      markerId: MarkerId(_myZone.toString()),
      infoWindow: InfoWindow(title: _myZone.toString(), snippet: "this is zone 7"),
      position: LatLng(_locationData!.latitude as double, _locationData!.longitude as double),
    );
    markersSet.add(cameraMarker);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getPermission();
    // getLocationRealTime();
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polygons: MyZones().myPolygon(),
            markers: markersSet,
            initialCameraPosition: cameraPosition,
          ),
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 20,
                child: ListView.builder(
                  itemCount: dList.length,
                  itemBuilder: (context, index) {
                    if (dList.isNotEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            '${dList[index][1]['time']} ${dList[index][1]['zone']} ${dList[index][0]}',
                            style: TextStyle(fontSize: 22.0),
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('Please wait'),
                      );
                    }
                  },
                ),
              ),
              ElevatedButton(
                child: const Text('click'),
                onPressed: () {
                  getLocation();
                },
              ),
              Container(
                color: Colors.grey.withOpacity(0.6),
                child: Text(
                  driverId,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
