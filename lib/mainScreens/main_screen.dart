import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lokaluser/assistants/assistant_methods.dart';
import 'package:lokaluser/global/global.dart';
import 'package:lokaluser/mainScreens/rate_driver_screen.dart';
import 'package:lokaluser/mainScreens/search_places_screen.dart';
import 'package:lokaluser/mainScreens/select_nearest_active_driver_screen.dart';
import 'package:provider/provider.dart';

import '../InfoHandler/app_info.dart';
import '../geofire_assistant.dart';
import '../main.dart';
import '../models/active_nearby_available_drivers.dart';
import '../models/directions.dart';
import '../salam/myzones.dart' as myzone;
import '../widgets/my_drawer.dart';
import '../widgets/pay_fare_amount_dialog.dart';
import '../widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(32.594863539518116, 44.01412402294828),
    zoom: 14,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 230;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;
  String driverRideStatus = "Driver is Coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";
  bool requestPositionInfo = true;

//----to find the zone
  String? _userZone;
  String driverId = '';

  dynamic driverInfo;

  blackThemeGoogleMap() {
    /* newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');*/
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  getSortedDriver() async {
    try {
      var ref = FirebaseDatabase.instance.ref().child("activeDrivers");
      DataSnapshot d = await ref.get();
      if (d.value != null) {
        var f = d.value as Map;

        var newMap = Map.fromEntries(
          f.entries.toList()
            ..sort(
              (e1, e2) => DateTime.parse(e1.value["time"]!).compareTo(
                DateTime.parse(e2.value["time"]!),
              ),
            ),
        );

        // print(newMap);
        dList = [];
        newMap.forEach((key, value) {
          dList.add([key, value]);
        });

        dList.forEach((element) {
          print('${element[0]} ${element[1]['time']} : ${element[1]['zone']}');
        });
        print('----------------------------');
        // print(dList.firstWhere((element) => element[1]['zone'] == _myZone)[0]);

        driverId = dList.firstWhere((element) => element[1]['zone'] == _userZone)[0];
        driverInfo = dList.firstWhere((element) => element[1]['zone'] == _userZone);
        //  driverLifeTimePosition(driverInfo);
      } else {
        print('no drivers');
      }
    } catch (e) {
      print('error is ${e.toString()}');
    }
  }

  driverLifeTimePosition(dynamic driverInfo) {
    print('driver info $driverInfo');
    print('driver lat ${driverInfo[1]['l'][0]}');

    Marker driverMarker = Marker(
        markerId: const MarkerId("driverID"),
        infoWindow: InfoWindow(title: driverInfo[0], snippet: "driver"),
        position: LatLng(driverInfo[1]['l'][0], driverInfo[1]['l'][1]),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet));
    // icon: createActiveNearByDriverIconMarker());

    setState(() {
      markersSet.add(driverMarker);
    });
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    Point userPoint = Point(cPosition.latitude, cPosition.longitude);
    _userZone = myzone.MyZones().getZoneNameByPoint(userPoint);
    print('userZone: $_userZone');
    getSortedDriver();
    print('driverId $driverId');

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    // initializeGeoFireListener();
    AssistantMethods.readTripsKeysForOnlineUser(context);
  }

  saveRideRequestInformation() {
    //1. save the RideRequest Information
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      //"key": value,
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //"key": value,
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformationMap);
    showWaitingResponseFromDriverUI();

    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }

      if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
        setState(() {
          driverCarDetails = (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["driverPhone"] != null) {
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["driverName"] != null) {
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
      }

      if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
        double driverCurrentPositionLat =
            double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLng =
            double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());

        LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        //status = accepted
        if (userRideRequestStatus == "accepted") {
          showUIForAssignedDriverInfo();
          //updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
        }

        //status = arrived
        if (userRideRequestStatus == "arrived") {
          setState(() {
            driverRideStatus = "Driver has Arrived";
          });
        }

        //status = ontrip
        if (userRideRequestStatus == "ontrip") {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }

        //status = ended
        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext c) => PayFareAmountDialog(
                fareAmount: fareAmount,
              ),
            );

            if (response == "cashPayed") {
              //user can rate the driver now
              if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
                String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => RateDriverScreen(
                              assignedDriverId: assignedDriverId,
                            )));

                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    // onlineNearByAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
    searchOnlineDriversByZone();
  }

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickUpPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus = "Driver is Coming :: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(dropOffLocation!.locationLatitude!, dropOffLocation.locationLongitude!);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus = "Going towards Destination :: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  searchOnlineDriversByZone() async {
    //no active driver available
    /*if (onlineNearByAvailableDriversList.isEmpty) {
      //cancel/delete the RideRequest Information
      referenceRideRequest!.remove();

      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });

      Fluttertoast.showToast(
          msg: "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");

      Future.delayed(const Duration(milliseconds: 2000), () {
        // Navigator.pop(context);
      });

      return;
    }
*/
    //active driver available
    /*await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SelectNearestActiveDriversScreen(referenceRideRequest: referenceRideRequest)));*/
    print('my driver id $driverId');
    FirebaseDatabase.instance.ref().child("drivers").child(driverId).once().then((snap) {
      if (snap.snapshot.value != null) {
        //send notification to that specific driver
        sendNotificationToDriverNow(driverId);

        //Display Waiting Response UI from a Driver
        // showWaitingResponseFromDriverUI();

        //Response from a Driver
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(driverId)
            .child("FnewRideStatus")
            .onValue
            .listen((eventSnapshot) {
          //1. driver has cancel the rideRequest :: Push Notification
          // (newRideStatus = idle)
          if (eventSnapshot.snapshot.value == "idle") {
            //   Fluttertoast.showToast(msg: "The driver has cancelled your request. Please choose another driver.");

            Future.delayed(const Duration(milliseconds: 100), () {
              //  Fluttertoast.showToast(msg: "Please Restart App Now.");

              waitingResponseFromDriverContainerHeight = 220;
              searchLocationContainerHeight = 0;
              assignedDriverInfoContainerHeight = 0;

              setState(() {});

              // Navigator.pop(context);
              // MyApp.restartApp(context);
            });
          }

          //2. driver has accept the rideRequest :: Push Notification
          // (newRideStatus = accepted)
          if (eventSnapshot.snapshot.value == "accepted") {
            //design and display ui for displaying assigned driver information
            showUIForAssignedDriverInfo();
          }
        });
      } else {
        // Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
      }
    });
  }

  showUIForAssignedDriverInfo() {
    print('showUIForAssignedDriverInfo');
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriverUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  sendNotificationToDriverNow(String chosenDriverId) {
    //assign/SET rideRequestId to newRideStatus in
    // Drivers Parent node for that specific choosen driver
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);

    //automate the push notification service
    FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId).child("token").once().then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();

        //send Notification Now
        AssistantMethods.sendNotificationToDriverNow(
          deviceRegistrationToken,
          referenceRideRequest!.key.toString(),
          context,
        );

        // Fluttertoast.showToast(msg: "Notification sent Successfully.");
      } else {
        //  Fluttertoast.showToast(msg: "Please choose another driver.");
        return;
      }
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    dList = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref.child(onlineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();

    // locateUserPosition();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    markersSet.clear();
    //streamSubscriptionPosition!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();

    return SafeArea(
      child: Scaffold(
        key: sKey,
        drawer: SizedBox(
          width: 265,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.black,
            ),
            child: MyDrawer(
              name: userName,
              email: userEmail,
            ),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polygons: myzone.MyZones().myPolygon(),
              polylines: polyLineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                //for black theme google map
                //  blackThemeGoogleMap();
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                locateUserPosition();
              },
            ),

            //custom hamburger button for drawer
            Positioned(
              top: 30,
              left: 14,
              child: GestureDetector(
                onTap: () {
                  if (openNavigationDrawer) {
                    sKey.currentState!.openDrawer();
                  } else {
                    //restart-refresh-minimize app progmatically
                    Navigator.pop(context);
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(
                    openNavigationDrawer ? Icons.menu : Icons.close,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),

            //ui for searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                curve: Curves.easeIn,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  height: searchLocationContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      children: [
                        //from
                        InkWell(
                          onTap: () {
                            Directions? directions2 = Directions();
                            directions2.locationName = '';
                            context.read<AppInfo>().updateDropOffLocationAddress(directions2);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => SearchPlacesScreen(
                                  orgOrDes: 'origin',
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_location,
                                color: Colors.red,
                              ),
                              const SizedBox(
                                width: 12.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "From",
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    Provider.of<AppInfo>(context).userPickUpLocation != null
                                        ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(
                                                0,
                                                Provider.of<AppInfo>(context)
                                                            .userPickUpLocation!
                                                            .locationName!
                                                            .toString()
                                                            .length >
                                                        40
                                                    ? 40
                                                    : Provider.of<AppInfo>(context)
                                                        .userPickUpLocation!
                                                        .locationName!
                                                        .toString()
                                                        .length) +
                                            "..."
                                        : "not getting address",
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                              /*const SizedBox(
                                width: 20.0,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  //go to search places screen
                                  var responseFromSearchScreen = await Navigator.push(
                                      context, MaterialPageRoute(builder: (c) => SearchPlacesScreen()));

                                  if (responseFromSearchScreen == "obtainedDropoff") {
                                    setState(() {
                                      openNavigationDrawer = false;
                                    });

                                    //draw routes - draw polyline
                                    await drawPolyLineFromOriginToDestination();
                                  }
                                },
                                child: Text(
                                  'another address',
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.purple,
                                  //  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                  // textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                                ),
                              )*/
                            ],
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white,
                        ),

                        const SizedBox(height: 16.0),

                        //to
                        InkWell(
                          onTap: () async {
                            //go to search places screen
                            var responseFromSearchScreen = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => SearchPlacesScreen(
                                          orgOrDes: 'des',
                                        )));

                            if (responseFromSearchScreen == "obtainedDropoff") {
                              setState(() {
                                openNavigationDrawer = false;
                              });

                              //draw routes - draw polyline
                              await drawPolyLineFromOriginToDestination();
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_location,
                                color: Colors.green,
                              ),
                              const SizedBox(
                                width: 12.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "To",
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    Provider.of<AppInfo>(context).userDropOffLocation != null
                                        ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                        : "Where to go?",
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white,
                        ),

                        const SizedBox(height: 16.0),

                        Row(
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              child: const Text(
                                "Request a Ride",
                              ),
                              onPressed: () {
                                if (Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null &&
                                    Provider.of<AppInfo>(context, listen: false).userDropOffLocation!.locationName !=
                                        '') {
                                  if (driverInfo != null) {
                                    getSortedDriver();
                                    saveRideRequestInformation();
                                    driverLifeTimePosition(driverInfo);
                                  } else {
                                    Fluttertoast.showToast(msg: "No drivers in zone");
                                  }
                                } else {}
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              child: const Text(
                                "change",
                              ),
                              onPressed: () {
                                locateUserPosition();
                                /* setState(() {
                                  searchLocationContainerHeight = 10;
                                });*/
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //ui for waiting response from driver
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: waitingResponseFromDriverContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          'please wait',
                          style: TextStyle(color: Colors.white),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              MyApp.restartApp(context);
                            },
                            child: Text('Restart App')),
                        AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                              'Waiting for Response\nfrom Driver',
                              duration: const Duration(seconds: 6),
                              textAlign: TextAlign.center,
                              textStyle:
                                  const TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            ScaleAnimatedText(
                              'Please wait...',
                              duration: const Duration(seconds: 10),
                              textAlign: TextAlign.center,
                              textStyle: const TextStyle(fontSize: 32.0, color: Colors.white, fontFamily: 'Canterbury'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //ui for displaying assigned driver information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: assignedDriverInfoContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //status of ride
                      Center(
                        child: Text(
                          driverRideStatus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10.0,
                      ),

                      const Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.white54,
                      ),

                      const SizedBox(
                        height: 10.0,
                      ),

                      //driver vehicle details
                      Text(
                        driverCarDetails,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(
                        height: 2.0,
                      ),

                      //driver name
                      Text(
                        driverName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(
                        height: 10.0,
                      ),

                      const Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.white54,
                      ),

                      const SizedBox(
                        height: 20.0,
                      ),

                      //call driver button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          icon: const Icon(
                            Icons.phone_android,
                            color: Colors.black54,
                            size: 22,
                          ),
                          label: const Text(
                            "Call Driver",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    /* print("These are points = ");
    print(directionDetailsInfo!.e_points);*/

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    CameraPosition cameraPosition = CameraPosition(target: destinationLatLng, zoom: 18);
/*
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));*/

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 50)!.listen((map) {
      print('drivers map $map');
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              //   displayActiveDriversOnUsersMap();
            }
            break;

          //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            //  displayActiveDriversOnUsersMap();
            break;

          //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
            // displayActiveDriversOnUsersMap();
            break;

          //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            // displayActiveDriversOnUsersMap();
            break;
        }
      }

      //  setState(() {});
    });
  }

  displayActiveDriversOnUsersMap() {
    /* setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for (ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver" + eachDriver.driverId!),
          infoWindow: InfoWindow(title: eachDriver.driverId!.toString()),
          position: eachDriverActivePosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          rotation: 360,
        );

        driversMarkerSet.add(marker); //removed by salam
      }

      setState(() {
        markersSet = driversMarkerSet;
      });
    });*/
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(0.1, 0.1));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value) {
        activeNearbyIcon = value;
      });
    }
  }
}
