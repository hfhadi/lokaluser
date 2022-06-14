import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_utils/google_maps_utils.dart' as utils;
import 'package:map_picker/map_picker.dart';

import 'package:lokaluser/models/zone.dart';

class ZoneWidget extends StatefulWidget {
  const ZoneWidget({Key? key}) : super(key: key);

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
  Zone zone1 = Zone(
      latitude: 32.5968879448776, longitude: 44.00242892636901, name: 'zone1');
  Zone zone2 = Zone(
      latitude: 32.58949395086726, longitude: 44.00517631645241, name: 'zone2');
  Zone zone3 = Zone(
      latitude: 32.5912834701241, longitude: 44.023029005095, name: 'zone3');
  Zone zone4 = Zone(
      latitude: 32.60049169459803,
      longitude: 44.012386625776735,
      name: 'zone4');

  Zone zone5 = Zone(
      latitude: 32.60027448919662, longitude: 44.02363160207539, name: 'zone5');

  Set<Marker> markersSet = {};
  Set<Marker> markersSet2 = {};
  double markerPostionLat = 32.594863539518116;
  double markerPositionLong = 44.01412402294828;

  List<Zone>? zoneList;

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
    target: LatLng(32.594863539518116, 44.01412402294828),
    zoom: 14,
  );
  CameraPosition cameraPosition2 = const CameraPosition(
    target: LatLng(32.594863539518116, 44.01412402294828),
    zoom: 14,
  );
  Marker? originMarker;
  Marker? originMarker2;
  Marker? originMarker3;
  Marker? originMarker4;
  Marker? originMarker5;
  Marker? cameraMarker;
  BitmapDescriptor? activeNearbyIcon;
  BitmapDescriptor? activeNearbyIcon2;
  MapPickerController mapPickerController = MapPickerController();

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Set<Polygon> myPolygon() {
    var polygonCorrd = <LatLng>[];
    polygonCorrd.add(LatLng(zone1.latitude!, zone1.longitude!));
    polygonCorrd.add(LatLng(zone2.latitude!, zone2.longitude!));
    polygonCorrd.add(LatLng(zone3.latitude!, zone3.longitude!));
    polygonCorrd.add(LatLng(zone4.latitude!, zone4.longitude!));
    polygonCorrd.add(LatLng(zone5.latitude!, zone5.longitude!));

    var polygonSet = <Polygon>{};
    polygonSet.add(
      Polygon(
          polygonId: const PolygonId('1'),
          points: polygonCorrd,
          strokeWidth: 2,
          fillColor: Colors.black12,
          strokeColor: Colors.red),
    );
    return polygonSet;
  }

  getMarkers() {
    // createActiveNearByDriverIconMarker();

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
    originMarker = Marker(
      markerId: const MarkerId("zone1"),
      infoWindow: const InfoWindow(
        title: 'Zone1',
        snippet: "Origin",
        anchor: Offset(0.5, 0.0),
      ),
      position: LatLng(zone1.latitude!, zone1.longitude!),
      // icon: BitmapDescriptor.fromBytes(bytes),
      /* onTap: () {
        setState(() {
          markersSet
              .addAll(<Marker>{originMarker!, originMarker2!, originMarker3!});
        });
      }, */
    );
    originMarker2 = Marker(
      /*  onTap: () {
          setState(() {
            markersSet.removeAll(<Marker>{originMarker2!, originMarker3!});
          });
        }, */
      markerId: const MarkerId("zone2"),
      infoWindow: const InfoWindow(title: 'Zone 2', snippet: "this is zone 2"),
      position: LatLng(zone2.latitude!, zone2.longitude!),
      //  icon: markerbitmap
    );

    originMarker3 = Marker(
      markerId: const MarkerId("zone3"),
      infoWindow: const InfoWindow(title: 'Zone 3', snippet: "this is zone 3"),
      position: LatLng(zone3.latitude!, zone3.longitude!),
      // icon: activeNearbyIcon!
    );
    originMarker4 = Marker(
      markerId: const MarkerId("zone4"),
      infoWindow: const InfoWindow(title: 'Zone 4', snippet: "this is zone 4"),
      position: LatLng(zone4.latitude!, zone4.longitude!),
    );
    originMarker5 = Marker(
      markerId: const MarkerId("zone5"),
      infoWindow: const InfoWindow(title: 'Zone 5', snippet: "this is zone 5"),
      position: LatLng(zone5.latitude!, zone5.longitude!),
    );
    originMarker5 = Marker(
      markerId: const MarkerId("zone5"),
      infoWindow: const InfoWindow(title: 'Zone 5', snippet: "this is zone 5"),
      position: LatLng(zone5.latitude!, zone5.longitude!),
    );

    cameraMarker = Marker(
      markerId: const MarkerId("zone5"),
      infoWindow: const InfoWindow(title: 'Zone 5', snippet: "this is zone 5"),
      position: LatLng(markerPostionLat, markerPositionLong),
    );

    markersSet.addAll(<Marker>{
      originMarker!,
      originMarker2!,
      originMarker3!,
      originMarker4!,
      originMarker5!
    });

    markersSet2.add(cameraMarker!);

    setState(() {});
  }

  late Marker f;
  int g = 0;
  getLat() async {
    // markersSet2.remove(f);
    g++;
    //
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2/map");
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
    // markersSet2.remove(f);
    g++;
    //
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2/map");
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

  @override
  void initState() {
    getMarkers();
    super.initState();
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(155, 155));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/carmarker3.jpeg")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
    if (activeNearbyIcon2 == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(55, 55));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/carmarker.jpeg")
          .then((value) {
        activeNearbyIcon2 = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // createActiveNearByDriverIconMarker();
    return SafeArea(
      child: Stack(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.end,

            // textDirection: TextDirection.rtl,

            children: [
              Expanded(
                child: MapPicker(
                  // pass icon widget
                  iconWidget: Image.asset(
                    "images/carmarker.jpeg",
                    height: 50,
                  ),
                  //add map picker controller
                  mapPickerController: mapPickerController,
                  child: GoogleMap(
                    markers: markersSet,
                    // circles: circles,
                    polygons: myPolygon(),
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
                    onCameraMoveStarted: () {
                      // notify map is moving
                      mapPickerController.mapMoving!();
                      textController.text = "checking ...";
                    },
                    onCameraMove: (cameraPosition) {
                      this.cameraPosition = cameraPosition;
                    },
                    onCameraIdle: () async {
                      getLatUpdate();

                      Point point = Point(cameraPosition.target.latitude,
                          cameraPosition.target.longitude);

                      /// Triangle
                      List<Point> polygon = [
                        Point(zone1.latitude as num, zone1.longitude as num),
                        Point(zone2.latitude as num, zone2.longitude as num),
                        Point(zone3.latitude as num, zone3.longitude as num),
                        Point(zone4.latitude as num, zone4.longitude as num),
                        Point(zone5.latitude as num, zone5.longitude as num),
                      ];

                      bool contains =
                          utils.PolyUtils.containsLocationPoly(point, polygon);
                      print('point is inside polygon?: $contains');

                      /// And Many more

                      setState(() {
                        markerPostionLat = cameraPosition.target.latitude;
                        markerPositionLong = cameraPosition.target.longitude;
                      });
                      print('cameraPositionLat=' + markerPostionLat.toString());
                      zoneList = [];
                      // notify map stopped moving
                      mapPickerController.mapFinishedMoving!();

                      zoneList!
                          .addAll(<Zone>{zone1, zone2, zone3, zone4, zone5});
                      /*    print(
                          '${placemarks.first.street}, ${placemarks.first.postalCode}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.subLocality}');
               */
                      for (Zone myzone in zoneList!) {
                        myzone.distance = calculateDistance(
                            myzone.latitude!,
                            myzone.longitude,
                            cameraPosition.target.latitude,
                            cameraPosition.target.longitude);
                      }

                      zoneList!
                          .sort(((a, b) => a.distance!.compareTo(b.distance!)));

                      textController.text = zoneList![0].name.toString() +
                          ':' +
                          zoneList![0].distance.toString() +
                          '\n' +
                          zoneList![1].name.toString() +
                          ':' +
                          zoneList![1].distance.toString() +
                          '\n currentposition' +
                          cameraPosition.target.latitude.toString() +
                          ',' +
                          cameraPosition.target.longitude.toString();
                      textController.text +=
                          '\n point is inside polygon? $contains';

                      FirebaseDatabase.instance
                          .ref()
                          .child(
                              "activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2/map")
                          .update({'lat': cameraPosition.target.latitude});
                      FirebaseDatabase.instance
                          .ref()
                          .child(
                              "activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2/map")
                          .update({'long': cameraPosition.target.longitude});
                    },
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
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
                    }),
              ),
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
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20,
            left: 10,
            right: 10,
            height: 120,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  readOnly: true,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none),
                  controller: textController,
                ),
              ),
            ),
          ),
          Positioned(
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
                  print(
                      "Location ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}");
                  print("Address: ${textController.text}");
                  setState(() {
                    markerPostionLat = cameraPosition.target.latitude;
                    markerPositionLong = cameraPosition.target.longitude;
                    print('markerPosition=' + markerPostionLat.toString());
                  });
                  setState(() {});
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFFA3080C)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
