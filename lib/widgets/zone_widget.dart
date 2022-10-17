import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_utils/google_maps_utils.dart' as utils;
import 'package:lokaluser/mainScreens/main_screen.dart';
import 'package:lokaluser/salam/myzones.dart';
import 'package:map_picker/map_picker.dart';

import 'package:lokaluser/models/zone.dart';

import '../assistants/assistant_methods.dart';
import '../assistants/geofire_assistant.dart';
import '../global/global.dart';
import '../models/active_nearby_available_drivers.dart';

class ZoneWidget extends StatefulWidget {
  const ZoneWidget({Key? key}) : super(key: key);

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
/*  Zone point1 = Zone(latitude: 32.5968879448776, longitude: 44.00242892636901, name: 'zone1');
  Zone point2 = Zone(latitude: 32.58949395086726, longitude: 44.00517631645241, name: 'zone2');
  Zone point3 = Zone(latitude: 32.5912834701241, longitude: 44.023029005095, name: 'zone3');
  Zone point4 = Zone(latitude: 32.60049169459803, longitude: 44.012386625776735, name: 'zone4');

  Zone point5 = Zone(latitude: 32.5898980, longitude: 44.0362529, name: 'zone5');
  Zone point6 = Zone(latitude: 32.5878758, longitude: 44.0294773, name: 'zone5');
  Zone point7 = Zone(latitude: 32.5885149, longitude: 44.0327339, name: 'zone5');*/

  Set<Marker> markersSet = {};
  Set<Marker> markersSet2 = {};
  double markerPostionLat = 32.594863539518116;
  double markerPositionLong = 44.01412402294828;
  LocationPermission? _locationPermission;

  String driverIdString = '';

  List<Zone> zoneList = [];

  Set<Circle> circles = {
    const Circle(
      circleId: CircleId('salam'),
      center: LatLng(32.594863539518116, 44.01412402294828),
      radius: 1000,
    )
  };

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newGoogleMapController;
  var textController = TextEditingController();

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(32.5939957863419, 44.01961718701079),
    zoom: 14,
  );
  CameraPosition cameraPosition2 = const CameraPosition(
    target: LatLng(32.5939957863419, 44.01961718701079),
    zoom: 14,
  );

  Marker? cameraMarker;

  MapPickerController mapPickerController = MapPickerController();
  bool activeNearbyDriverKeysLoaded = false;

  Position? userCurrentPosition;

  var ref = FirebaseDatabase.instance.ref().child("activeDrivers");

  String currentZoneName = '';
  late DateTime nowTime;

  /* double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getMarkers() async {
    // createActiveNearByDriverIconMarker();

    */
  /*  String imgurl = "https://www.fluttercampus.com/img/car.png";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
        .buffer
        .asUint8List();
    ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context, size: const Size(155, 155));
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      "images/prayer.png",
    ); */
  /*  originMarker = Marker(
      markerId: const MarkerId("zone1"),
      infoWindow: const InfoWindow(
        title: 'Zone1',
        snippet: "Origin",
        anchor: Offset(0.5, 0.0),
      ),
      position: LatLng(point1.latitude!, point1.longitude!),
      // icon: BitmapDescriptor.fromBytes(bytes),
      */
  /* onTap: () {
        setState(() {
          markersSet
              .addAll(<Marker>{originMarker!, originMarker2!, originMarker3!});
        });
      }, */


  /*  onTap: () {
          setState(() {
            markersSet.removeAll(<Marker>{originMarker2!, originMarker3!});
          });
        }, */

  /*
      markerId: const MarkerId("zone2"),
      infoWindow: const InfoWindow(title: 'Zone 2', snippet: "this is zone 2"),
      position: LatLng(point2.latitude!, point2.longitude!),
      //  icon: markerbitmap
    );

    originMarker3 = Marker(
      markerId: const MarkerId("zone3"),
      infoWindow: const InfoWindow(title: 'Zone 3', snippet: "this is zone 3"),
      position: LatLng(point3.latitude!, point3.longitude!),
      // icon: activeNearbyIcon!
    );
    originMarker4 = Marker(
      markerId: const MarkerId("zone4"),
      infoWindow: const InfoWindow(title: 'Zone 4', snippet: "this is zone 4"),
      position: LatLng(point4.latitude!, point4.longitude!),
    );
    originMarker5 = Marker(
      markerId: const MarkerId("zone5"),
      infoWindow: const InfoWindow(title: 'Zone 5', snippet: "this is zone 5"),
      position: LatLng(point5.latitude!, point5.longitude!),
    );
    */

  /*

    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    try {
      originMarker6 = Marker(
          markerId: const MarkerId("zone6"),
          infoWindow: const InfoWindow(title: 'Zone 6', snippet: "this is zone 6"),
          position: LatLng(cPosition.latitude, cPosition.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow));

      markersSet.add(originMarker6!);
      setState(() {});
    } catch (e) {
      print('printing ${e.toString()}');
    }

    cameraMarker = Marker(
      markerId: const MarkerId("zone7"),
      infoWindow: const InfoWindow(title: 'currentPosition', snippet: "this is zone 7"),
      position: LatLng(markerPostionLat, markerPositionLong),
    );

    markersSet.addAll(<Marker>{originMarker!, originMarker2!, originMarker3!, originMarker4!, originMarker5!});

    // markersSet2.add(cameraMarker!);

    setState(() {});
  }

  late Marker f;
  int g = 0;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    print('current position $cPosition');

    // initializeGeoFireListener();
    // AssistantMethods.readTripsKeysForOnlineUser(context);
  }

  getLat() async {
    // markersSet2.remove(f);
    g++;
    //
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2/map");
    DatabaseEvent elat = await ref.child('lat').once();
    DatabaseEvent elong = await ref.child('long').once();
    print('this is the lat: ${elat.snapshot.value}');
    double lat = elat.snapshot.value as double;
    double long = elong.snapshot.value as double;

    f = Marker(
      markerId: MarkerId("salman" + g.toString()),
      infoWindow: InfoWindow(title: 'Zone 5 $g', snippet: "this is zone 5"),
      position: LatLng(lat, long),
    );

    markersSet2.add(f);
  }

  getLatUpdate() async {
    // markersSet2.clear();
    g++;
    //
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2/map");
    DatabaseEvent elat = await ref.child('lat').once();
    DatabaseEvent elong = await ref.child('long').once();
    print('this is the lat: ${elat.snapshot.value}');
    double lat = elat.snapshot.value as double;
    double long = elong.snapshot.value as double;

    f = Marker(
      markerId: MarkerId("salman" + g.toString()),
      infoWindow: InfoWindow(title: 'Zone 5 $g', snippet: "this is zone 5"),
      position: LatLng(lat, long),
    );

    markersSet2.add(f);
    //setState(() {});
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      //circlesSet.clear();

      Set<Marker> driversMarkerSet = <Marker>{};

      for (ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver" + eachDriver.driverId!),
          infoWindow: InfoWindow(title: eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          rotation: 360,
        );

        driversMarkerSet.add(marker); //removed by salam
      }

      setState(() {
        markersSet = driversMarkerSet;
      });
    });
  }
*/
  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  /* locateUserPosition2() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    */
  /*   LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

     CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

     newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);*/
  /*

    initZer();
    //AssistantMethods.readTripsKeysForOnlineUser(context);
  }
*/
  /* initZer() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']
        //print('callBack = $callBack');
        switch (callBack) {

          //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              // displayActiveDriversOnUsersMap();
            }
            break;

          //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            // displayActiveDriversOnUsersMap();
            break;

          //whenever driver moves - update driver location
          */
  /* case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;*/
  /*

          //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            //displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }*/

  /* sortTime() {
    List<DateTime> timeList = [];
    var time1 = DateTime.utc(1989, 11, 9, 23, 10, 14).subtract(const Duration(seconds: 5));
    var time2 = DateTime.utc(1989, 11, 9, 23, 12, 17);
    var time3 = DateTime.utc(1989, 11, 9, 23, 15, 14);
    var time4 = DateTime.utc(1989, 11, 9, 23, 10, 54);
    var time5 = DateTime.utc(1989, 11, 9, 23, 8, 54);
    var time6 = DateTime.utc(1989, 11, 9, 23, 5, 54);
    var time7 = DateTime.utc(1989, 11, 9, 23, 1, 54);
    var time8 = DateTime.utc(1989, 11, 9, 23, 1, 55);
    timeList.addAll([time1, time2, time3, time4, time5, time6, time7, time8]);

    timeList.sort(((a, b) => a.compareTo(b)));
    timeList.forEach((element) {
      print(element);
    });
  }*/

  @override
  void initState() {
    checkIfLocationPermissionAllowed();
    //locateUserPosition2();
    // sortTime();
    //locateUserPosition();
    //getMarkers();
    //locateUserPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // createActiveNearByDriverIconMarker();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            MapPicker(
              // pass icon widget
              iconWidget: Image.asset(
                "images/car.png",
                height: 50,
              ),

              mapPickerController: mapPickerController,
              child: GoogleMap(
                // markers: markersSet,
                // circles: circles,
                polygons: MyZones().myPolygon(),
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                // hide location button
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                //  camera position
                initialCameraPosition: cameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);

                  //getLat();
                  // locateUserPosition2();

                  //  displayActiveDriversOnUsersMap();
                  textController.text = "start ...";

                  /* zoneList.addAll(<Zone>{point1, point2, point3, point4, point5});

                        for (Zone myzone in zoneList) {
                          myzone.distance = calculateDistance(myzone.latitude!, myzone.longitude,
                              cameraPosition.target.latitude, cameraPosition.target.longitude);
                        }

                        zoneList.sort(((a, b) => a.distance!.compareTo(b.distance!)));
                        setState(() {
                          textController.text = zoneList[0].name.toString() +
                              ':' +
                              zoneList[0].distance.toString() +
                              '\n' +
                              zoneList[1].name.toString() +
                              ':' +
                              zoneList[1].distance.toString();
                        });*/
                },
                onCameraMoveStarted: () {
                  // notify map is moving
                  mapPickerController.mapMoving!();
                  textController.text = "checking ...";
                },
                onCameraMove: (cameraPosition) {
                  this.cameraPosition = cameraPosition;
                },
                onCameraIdle: () async {
                  // getLatUpdate();
                  //displayActiveDriversOnUsersMap();
                  // MyZones().myPolygon();
                  // print(cameraPosition);
                  var zone = MyZones().getZoneNameByCameraPosition(cameraPosition);

                  //MyZones().getPositionInZone(cameraPosition);

                  textController.text = zone +
                      '\n' +
                      cameraPosition.target.latitude.toString() +
                      ' ' +
                      cameraPosition.target.longitude.toString();

                  // Point point = Point(cameraPosition.target.latitude, cameraPosition.target.longitude);

                  /// Triangle

                  /// And Many more

                  /* setState(() {
                          markerPostionLat = cameraPosition.target.latitude;
                          markerPositionLong = cameraPosition.target.longitude;
                        });
                        //  print('cameraPositionLat=' + markerPostionLat.toString());
                        zoneList = [];
                        // notify map stopped moving
                        mapPickerController.mapFinishedMoving!();

                        zoneList.addAll(<Zone>{point1, point2, point3, point4, point5});
                        */ /*    print(
                            '${placemarks.first.street}, ${placemarks.first.postalCode}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.subLocality}');
                 */
                  /*
                        for (Zone myzone in zoneList!) {
                          myzone.distance = calculateDistance(myzone.latitude!, myzone.longitude,
                              cameraPosition.target.latitude, cameraPosition.target.longitude);
                        }

                        zoneList!.sort(((a, b) => a.distance!.compareTo(b.distance!)));

                        textController.text = zoneList![0].name.toString() +
                                ':' +
                                zoneList![0].distance.toString() +
                                '\n' +
                                zoneList![1].name.toString() +
                                ':' +
                                zoneList![1].distance.toString()*/
                  /*'\n currentposition' +
                            cameraPosition.target.latitude.toString() +
                            ',' +
                            cameraPosition.target.longitude.toString();
                        textController.text +=
                            '\n التحدي: $contains, الموظفين: $contains2, النصر: $contains3, سيف: $contains4, الاسكان: $contains5'
                            ;*/
                  // ref = ref.child(driverIdString);

                  if (currentZoneName != zone && driverIdString.isNotEmpty) {
                    print('driver string = $driverIdString');
                    currentZoneName = zone;
                    nowTime = DateTime.now();
                    print(DateTime.now().toUtc().toString());

                    ref.child('$driverIdString/time').set(DateTime.now().toUtc().toString());
                    ref.child('$driverIdString/zone').set(zone);
                    if (driverIdString.isNotEmpty) {
                      ref.child(driverIdString).update({'l/0': cameraPosition.target.latitude});
                      ref.child(driverIdString).update({'l/1': cameraPosition.target.longitude});
                    }
                  }
                },
              ),
            ),
            /*  Positioned(
              top: MediaQuery.of(context).viewPadding.top + 20,
              left: 10,
              right: 10,
              height: MediaQuery.of(context).size.height / 6,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none),
                    controller: textController,
                  ),
                ),
              ),
            ),*/
            Column(
              children: [
                TextField(
                  onChanged: (value) {},
                  onSubmitted: (value) {
                    print(value);
                    driverIdString = value;
                  },
                ),
                Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      readOnly: true,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none),
                      controller: textController,
                    ),
                  ),
                ),

                /*   Expanded(
                  child: GoogleMap(
                      markers: markersSet2,
                      zoomControlsEnabled: true,
                      // hide location button
                      myLocationButtonEnabled: true,
                      mapType: MapType.terrain,
                      //  camera position
                      initialCameraPosition: cameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);

                        // textController.text = "start ...";

                        */
                /* zoneList!
                            .addAll(<Zone>{zone1, zone2, zone3, zone4, zone5});

                        for (Zone myzone in zoneList!) {
                          myzone.distance = calculateDistance(
                              myzone.latitude!,
                              myzone.longitude,
                              cameraPosition.target.latitude,
                              cameraPosition.target.longitude);
                        }

                        zoneList!
                            .sort(((a, b) => a.distance!.compareTo(b.distance!)));
                        setState(() {
                          textController.text = zoneList![0].name.toString() +
                              ':' +
                              zoneList![0].distance.toString() +
                              '\n' +
                              zoneList![1].name.toString() +
                              ':' +
                              zoneList![1].distance.toString();
                        });
                      },
                      onCameraIdle: () async {
                        setState(() {
                          markerPostionLat = cameraPosition.target.latitude;
                          markerPositionLong = cameraPosition.target.longitude;
                        }); */
                /*
                      }),
                ),*/
                /*  Expanded(
                  child: GoogleMap(
                      markers: markersSet2,
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      // hide location button
                      myLocationButtonEnabled: true,
                      mapType: MapType.normal,
                      //  camera position
                      initialCameraPosition: cameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);

                        textController.text = "start ...";

                        zoneList!
                            .addAll(<Zone>{zone1, zone2, zone3, zone4, zone5});

                        for (Zone myzone in zoneList!) {
                          myzone.distance = calculateDistance(
                              myzone.latitude!,
                              myzone.longitude,
                              cameraPosition.target.latitude,
                              cameraPosition.target.longitude);
                        }

                        zoneList!
                            .sort(((a, b) => a.distance!.compareTo(b.distance!)));
                        setState(() {
                          textController.text = zoneList![0].name.toString() +
                              ':' +
                              zoneList![0].distance.toString() +
                              '\n' +
                              zoneList![1].name.toString() +
                              ':' +
                              zoneList![1].distance.toString();
                        });
                      },
                      onCameraIdle: () async {
                        setState(() {
                          markerPostionLat = cameraPosition.target.latitude;
                          markerPositionLong = cameraPosition.target.longitude;
                        });
                      }),
                ),
              */
              ],
            ),

            /*  Positioned(
              bottom: 124,
              left: 24,
              //right: 24,
              child: SizedBox(
                height: 50,
                child: TextButton(
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      color: Color(0xFFFFFFFF),
                      fontSize: 19,
                      // height: 19/19,
                    ),
                  ),
                  onPressed: () {
                    print("Location ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}");
                    print("Address: ${textController.text}");
                    setState(() {
                      markerPostionLat = cameraPosition.target.latitude;
                      markerPositionLong = cameraPosition.target.longitude;
                      print('markerPosition=' + markerPostionLat.toString());
                    });
                    setState(() {});
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFA3080C)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
