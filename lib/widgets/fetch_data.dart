import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/* Stream<DatabaseEvent>? stream;

class FetchData2 extends StatelessWidget {
  const FetchData2({Key? key}) : super(key: key);

  getUsers() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/123");

// Get the data once
    DatabaseEvent event = await ref.once();

// Print the data of the snapshot
    print(event.snapshot.value);

    stream = ref.onValue;

// Subscribe to the stream!
    stream!.listen((DatabaseEvent event) {
      print('Event Type: ${event.type}'); // DatabaseEventType.value;
      print('Snapshot: ${event.snapshot}'); // DataSnapshot
    });
  }

  @override
  Widget build(BuildContext context) {
    getUsers();
    return Scaffold(
      body: Center(
          child: StreamBuilder<Object>(
              stream: stream,
              builder: (context, snapshot) {
                print('snapchat: ${snapshot.data.toString()}');
                return const Text('hello world');
              })),
    );
  }
}

 */

class FetchData extends StatefulWidget {
  FetchData({
    Key? key,
  }) : super(key: key);

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  late DatabaseReference _dbref;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markersSet2 = {};
  Set<Marker> markersSet3 = {};

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

  Marker? cameraMarker;

  double markerPostionLat = 32.594863539518116;
  double markerPositionLong = 44.01412402294828;
  getMarkerTwo(double lat, double long) {
// Get the Stream
  }

  getMyData() {
    _dbref.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        var myValue = event.snapshot.value as Map;
        // ignore: avoid_print
        print(myValue['map']['lat'] ?? '');
        double myLat = myValue['map']['lat'];
        double mylong = myValue['map']['long'];
        cameraMarker = Marker(
          markerId: const MarkerId("zone5"),
          infoWindow: const InfoWindow(
              title: 'Zone 5\n zone2\n zone3', snippet: "this is zone 5"),
          position: LatLng(myLat, mylong),
        );
        markersSet2.add(cameraMarker!);
        setState(() {});
      }
    });
  }

  updateScreen() {
    setState(() {});
  }

  _createDB() {
    //  _dbref.child("profile").set(" my profile");
    _dbref
        .child("carprofile")
        .set({'lat': 34.23432, 'long': 44.234322, 'color': 'red'});
  }

  _updatevalue() {
    _dbref.child("carprofile").update({"car2": "big company car"});
  }

  _delete() {
    _dbref.remove();
  }

  @override
  void initState() {
    super.initState();

    _dbref = FirebaseDatabase.instance
        .ref('/activeDrivers/o0jKO5j8MNViFMmjjM5Yy9LZv6J2');
    getMarkerTwo(32.594863539518116, 44.01412402294828);
    //_createDB();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('salam'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GoogleMap(
                compassEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
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
                },
                onCameraIdle: () async {}),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StreamBuilder(
                  stream: _dbref.onValue,
                  builder: (context, AsyncSnapshot snap) {
                    if (snap.hasData &&
                        !snap.hasError &&
                        snap.data.snapshot.value != null) {
                      Map data = snap.data.snapshot.value;
                      List item = [];

                      data.forEach(
                          (index, data) => item.add({"key": index, ...data}));

                      Marker cameraMarker3 = Marker(
                        markerId: const MarkerId("zone5"),
                        infoWindow: const InfoWindow(
                            title: 'Zone 5\n zone2\n zone3',
                            snippet: "this is zone 5"),
                        position:
                            LatLng(data['map']['lat'], data['map']['long']),
                      );
                      markersSet3.add(cameraMarker3);

                      return Expanded(
                        child: ListView.builder(
                          itemCount: item.length,
                          itemBuilder: (context, index) {
                            return Text(
                                'lat: ${item[index]['lat'].toString()} \nlong: ${item[index]['long']}');
                          },
                        ),
                      );
                      /*  ListView.builder(
                            itemCount: item.length,
                            itemBuilder: (context, index) {
                              return Text(
                                  'lat: ${item[index]['lat'].toString()} \nlong: ${item[index]['long']}');
                            },
                          ), */

                    } else {
                      return Center(child: Text("No data"));
                    }
                  },
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _delete();
                        },
                        child: const Text('delete')),
                    ElevatedButton(
                        onPressed: () {
                          _createDB();
                        },
                        child: const Text('create')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
