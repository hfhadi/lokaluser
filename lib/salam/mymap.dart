import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lokaluser/InfoHandler/app_info.dart';
import 'package:lokaluser/models/zone.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker_updates.dart';

class MyMap extends StatefulWidget {
  const MyMap({Key? key}) : super(key: key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late double a;
  Set<Marker> markersSet2 = {};
  Set<Marker> markersSet3 = {};
  DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2/map");

  // GoogleMapController? newGoogleMapController;

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(32.594863539518116, 44.01412402294828),
    zoom: 14,
  );
  String myId = 'salam';
  String myId2 = 'zaynab';
  int nameIndex = 0;
  int nameIndex2 = 0;
  bool mBool = false;

  late Marker f;

  getMarker() async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(25, 25)),
      "images/destination_map_marker.png",
    );
    BitmapDescriptor markerbitmap2 = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(25, 25)),
      "images/driving_pin.png",
    );

    /*   String imgurl = "https://www.fluttercampus.com/img/car.png";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
        .buffer
        .asUint8List(); */

    f = Marker(
      markerId: MarkerId(myId + nameIndex.toString()),
      position: LatLng(
          32.594863539518116 +
              Provider.of<AppInfo>(context, listen: false).count,
          44.01412402294828),
      infoWindow: InfoWindow(
          title:
              'alibaba how are you ${Provider.of<AppInfo>(context, listen: false).count}',
          snippet: "salam"),
      icon: mBool ? markerbitmap : markerbitmap2,
      //icon: BitmapDescriptor.fromBytes(bytes),
    );
    markersSet2.add(f);
    setState(() {});
  }

  late Stream<DatabaseEvent> stream;

  getFirebaseData() async {
    /*  String imgurl = "https://www.fluttercampus.com/img/car.png";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
        .buffer
        .asUint8List(); */

    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(45, 45)),
      "images/driving_pin.png",
    );

    stream = ref.onValue;
    double lat;
    double long;
    print('Name of index ${nameIndex2}');
    Marker? m;
    stream.listen((DatabaseEvent event) {
      markersSet2.remove(m);

      nameIndex2++;
      lat = event.snapshot.child('lat').value as double;
      long = event.snapshot.child('long').value as double;

      // print(lat);

      m = Marker(
        markerId: MarkerId(myId2 + nameIndex2.toString()),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(
            title: 'alibaba how are you $lat $long', snippet: "salam"),
        icon: markerbitmap,
        // icon: BitmapDescriptor.fromBytes(bytes),
      );
      markersSet2.add(m!);
      //  print('Name of index ${nameIndex}');
      setState(() {});
      // DataSnapshot
    });
  }

  // context.read<AppInfo>().updateMarker(f);
  // markersSet2.remove(markersSet2);

  //update(BuildContext context) {}
  removeMarker() {
    markersSet2.remove(f);
  }

  @override
  void initState() {
    getMarker();
    getFirebaseData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // update(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: cameraPosition,
              markers: markersSet2,
            ),
            Text(context.watch<AppInfo>().count.toString()),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                // context.read<AppInfo>().increment();
                Provider.of<AppInfo>(context, listen: false).increment();

                /*  Marker f = Marker(
                  markerId: const MarkerId('salam2'),
                  position: LatLng(32.574863539518116, 44.01412402294828),
                  infoWindow: InfoWindow(title: 'hello', snippet: "salam"),
                ); */
                mBool = !mBool;

                removeMarker();
                nameIndex++;
                getMarker();

                /*  f = Marker(
                  markerId: MarkerId(myId + nameIndex.toString()),
                  position: LatLng(
                      33.593863539518116 +
                          Provider.of<AppInfo>(context, listen: false).count,
                      44.01412402294828),
                  infoWindow: InfoWindow(
                      title:
                          'alibaba how are you ${Provider.of<AppInfo>(context, listen: false).count}',
                      snippet: "salam"),
                ); */
                // getMarker(context);
                //   markersSet2.add(f);

                /* markersSet2.add(f);

                markersSet2.add(g); */
              },
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () => context.read<AppInfo>().reset(),
              child: Icon(Icons.exposure_zero),
            ),
            FloatingActionButton(
              onPressed: () {
                Provider.of<AppInfo>(context, listen: false).decrement();
                removeMarker();
                nameIndex++;
                getMarker();
                /*  Marker g = Marker(
                  markerId: const MarkerId('salam'),
                  position: LatLng(
                      33.794863539518116 +
                          Provider.of<AppInfo>(context, listen: false).count,
                      44.01412402294828),
                  infoWindow: InfoWindow(
                      title:
                          'zaynab how are you ${Provider.of<AppInfo>(context, listen: false).count}',
                      snippet: "salam"),
                );
                markersSet2.add(g); */
              },
              child: Icon(Icons.remove),
            ),
            /*  Card(
              child: StreamBuilder<Object>(
                  stream: stream,
                  builder: (context, AsyncSnapshot snap) {
                    if (snap.hasData) {
                      nameIndex++;
                      Map data = snap.data.snapshot.value;
                      return Text(data['lat'].toString());
                    } else {
                      return const Text('no');
                    }
                  }),
            ) */
          ],
        ),
      ),
    );
  }
}
