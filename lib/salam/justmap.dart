import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../InfoHandler/app_info.dart';
import 'myzones.dart';

class JustMap extends StatefulWidget {
  JustMap({Key? key}) : super(key: key);

  @override
  State<JustMap> createState() => _JustMapState();
}

class _JustMapState extends State<JustMap> {
  GoogleMapController? mapController; //contrller for Google map
  Set<Marker> markers = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref().child("activeDrivers"); //markers for google map

  /*  LatLng startLocation = LatLng(27.6602292, 85.308027);
  LatLng endLocation = LatLng(27.6599592, 85.3102498);
  LatLng carLocation = LatLng(27.659470, 85.3077363);
 */
  LatLng startLocation = const LatLng(32.594863539518116, 44.01412402294828);
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(32.594863539518116, 44.01412402294828),
    zoom: 14,
  );
  String myId = 'salam';
  String myId2 = 'zaynab';
  int nameIndex = 0;
  int nameIndex2 = 0;
  bool mBool = false;
  Set<Marker> markersSet = {};
  List<Marker>? markerList;
  Marker? m;
  Marker? m2;
  Marker? f;
  Marker? mk;
  double g = 0.01;
  bool getMarkers = false;
  Timer? timer;

  @override
  void initState() {
    //addMarkerOnce();
    // addMarkerStream();
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (Timer t) => {
        reamoveMarker2(),
        addMarkerOnce(),
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  reamoveMarker() {
    // markersSet.remove(f);
    // markersSet.remove(m);

    print(markersSet.length);
  }

  reamoveMarker2() {
    // markersSet.remove(f);
    // markersSet.remove(m);
    print('clear');
    markersSet.clear();
    setState(() {});
  }

  addMe() {
    // nameIndex2 = 0;

    nameIndex2++;
    g += 0.001;
    f = Marker(
      markerId: MarkerId('salam' + nameIndex2.toString()),
      position: LatLng(32.57486353951811 + g, 44.01432402294828 + g),
      infoWindow: InfoWindow(title: nameIndex2.toString(), snippet: 'keyf.toString()'),
      // icon: markerbitmap,
      // icon: BitmapDescriptor.fromBytes(bytes),
    );
    markersSet.add(f!);
    setState(() {});
    //markersSet.remove(f);
    print('add marker');
  }

  addMarkerOnce() async {
    g += 0.001;
    /**/
    nameIndex2 = 0;

    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(35, 35)),
      "images/driving_pin.png",
    );
    BitmapDescriptor markerbitmap2 = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(35, 35)),
      "images/carmarker.jpeg",
    );
    mBool = !mBool;
    double lat;
    double long;
    DatabaseEvent event = await ref.once();
    Map activeDrivers = event.snapshot.value as Map;
    // print(activeDrivers);

    activeDrivers.forEach((keyUserId, value) {
      print(value);
      Map myposition = value as Map;
      myposition.forEach((keyg, value) {
        // print(value);
        if (value is List) {
          List items = value;
          nameIndex2++;
          lat = items[0] as double;
          long = items[1] as double;
          // print('this is $lat');
          print('---------');
          /*  print('this is lat ${items[0]}');
            print('this is long ${items[1]}'); */

          m = Marker(
            markerId: MarkerId(keyUserId.toString()),
            position: LatLng(lat, long),
            infoWindow: InfoWindow(title: myposition['zone'].toString(), snippet: keyUserId.toString()),
            icon: myposition['zone'].toString().contains('اطباء') ? markerbitmap2 : markerbitmap,
            // icon: BitmapDescriptor.fromBytes(bytes),
          );

          markersSet.add(m!);

          setState(() {});
        }
      });
      print('zone value=${myposition['zone']}');
    });
  }

  addMarkerStream() async {
    g += 0.001;
    nameIndex2 = 0;

    double lat;
    double long;

    Stream<DatabaseEvent> stream = ref.onValue;

    stream.listen((DatabaseEvent event) {
      //  addMarkerOnce();
      reamoveMarker2();
      addMarkerOnce();
      /*Map keyd = event.snapshot.value as Map;

      keyd.forEach((keyf, value) {
        Map myposition = value as Map;
        myposition.forEach((keyg, value) {
          if (value is List) {
            List items = value;
            nameIndex2++;
            lat = items[0] as double;
            long = items[1] as double;
            print('this is $lat');
            print('---------');
            print('this is lat ${items[0]}');
            print('this is long ${items[1]}');

            m = Marker(
              markerId: MarkerId(keyf.toString()),
              position: LatLng(lat + g, long + g),
              infoWindow: InfoWindow(title: nameIndex2.toString(), snippet: keyf.toString()),
              // icon: markerbitmap,
              // icon: BitmapDescriptor.fromBytes(bytes),
            );

            markersSet.add(m!);

            setState(() {});
          }
        });
      });*/
    });

    /*  DatabaseEvent event = await ref.once();
    //print(event.snapshot.value);
    Map key = event.snapshot.value as Map;
    key.forEach((key, value) {
      Map myposition = value as Map;
      myposition.forEach((key, value) {
        if (value is List) {
          print(value);
        }
      });
    }); */

    /* BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(35, 35)),
      "images/driving_pin.png",
    );

    markers.add(Marker(
      //add start location marker
      markerId: MarkerId(startLocation.toString()),
      position: startLocation, //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Starting Point ',
        snippet: 'Start Marker',
      ),
      icon: markerbitmap, //Icon for Marker
    ));

    markers.add(Marker(
      //add start location marker
      markerId: MarkerId(endLocation.toString()),
      position: endLocation, //position of marker
      rotation: -45,
      infoWindow: InfoWindow(
        //popup info
        title: 'End Point ',
        snippet: 'End Marker',
      ),
      icon: markerbitmap, //Icon for Marker
    ));

    String imgurl = "https://www.fluttercampus.com/img/car.png";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
        .buffer
        .asUint8List();

    markers.add(Marker(
      //add start location marker
      markerId: MarkerId(carLocation.toString()),
      position: carLocation, //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Car Point ',
        snippet: 'Car Marker',
      ),
      icon: BitmapDescriptor.fromBytes(bytes), //Icon for Marker
    ));

    setState(() {
      //refresh UI
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Salam Map"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Stack(
          children: [
            GoogleMap(
              //Map widget from google_maps_flutter package
              zoomGesturesEnabled: true, //enable Zoom in, out on map
              initialCameraPosition: cameraPosition,
              polygons: MyZones().myPolygon(),
              markers: markersSet, //markers to show on map
              mapType: MapType.normal, //map type
              onMapCreated: (controller) {
                // addMarkerStream();

                //addMarkerOnce();
                setState(() {
                  mapController = controller;
                });
              },
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    addMarkerStream();
                  },
                  child: Text('addMarkerStream'),
                ),
                ElevatedButton(
                  onPressed: () {
                    addMarkerOnce();
                  },
                  child: Text('addMarkerOnce'),
                ),
                ElevatedButton(
                  onPressed: () {
                    reamoveMarker2();
                    addMarkerOnce();
                  },
                  child: Text('removeMarker'),
                )
              ],
            ),
          ],
        ));
  }
}
