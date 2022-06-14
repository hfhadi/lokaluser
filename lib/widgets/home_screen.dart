import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_controller/google_maps_controller.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final s = "Map 2";
  late final GoogleMapsController controller;
  late final StreamSubscription<CameraPosition> subscription;
  CameraPosition? position;

  @override
  void initState() {
    super.initState();

    controller = GoogleMapsController(
      mapToolbarEnabled: true,
      initialCameraPosition: const CameraPosition(
        target: LatLng(33.42796133580664, 44.085749655962),
        zoom: 14.4746,
      ),
      onTap: (latlng) {
        late Circle circle;
        circle = Circle(
          circleId: CircleId(
            "ID:" + DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          center: latlng,
          fillColor: Color.fromRGBO(255, 0, 0, 1),
          strokeColor: Color.fromRGBO(155, 0, 0, 1),
          radius: 5,
          onTap: () => controller.removeCircle(circle),
          consumeTapEvents: true,
        );

        controller.addCircle(circle);
      },
    );

    subscription = controller.onCameraMove$.listen((e) {
      setState(() {
        position = e;
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: GoogleMaps(
              controller: controller,
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Text(position?.toString() ?? 'Move the map'),
            ),
          )
        ],
      ),
    );
  }
}
