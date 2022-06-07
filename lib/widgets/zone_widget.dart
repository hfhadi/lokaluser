import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_picker/map_picker.dart';
import 'package:geocoding/geocoding.dart';

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
  List<Zone>? zoneList;

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newGoogleMapController;
  var textController = TextEditingController();

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(32.594863539518116, 44.01412402294828),
    zoom: 14,
  );
  Marker? originMarker;
  Marker? originMarker2;
  Marker? originMarker3;
  Marker? originMarker4;
  Marker? originMarker5;
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

    markersSet.addAll(<Marker>{
      originMarker!,
      originMarker2!,
      originMarker3!,
      originMarker4!,
      originMarker5!
    });

    setState(() {});
  }

  /*  setMarkers() {
    setState(() {
      markersSet.add(originMarker!);
      markersSet.add(originMarker2!);
      markersSet.add(originMarker3!);
    });
  } */

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
          MapPicker(
            // pass icon widget
            iconWidget: Image.asset(
              "images/carmarker.jpeg",
              height: 50,
            ),
            //add map picker controller
            mapPickerController: mapPickerController,
            child: GoogleMap(
              markers: markersSet,
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

                zoneList!.addAll(<Zone>{zone1, zone2, zone3, zone4, zone5});

                for (Zone myzone in zoneList!) {
                  myzone.distance = calculateDistance(
                      myzone.latitude!,
                      myzone.longitude,
                      cameraPosition.target.latitude,
                      cameraPosition.target.longitude);
                }

                zoneList!.sort(((a, b) => a.distance!.compareTo(b.distance!)));
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
                zoneList = [];
                // notify map stopped moving
                mapPickerController.mapFinishedMoving!();
                //get address name from camera position
                /*  List<Placemark> placemarks = await placemarkFromCoordinates(
                  cameraPosition.target.latitude,
                  cameraPosition.target.longitude,
                ); */

                /* zone1.distance = calculateDistance(
                    zone1.latitude!,
                    zone1.longitude,
                    cameraPosition.target.latitude,
                    cameraPosition.target.longitude);
                zone2.distance = calculateDistance(
                    zone2.latitude!,
                    zone2.longitude,
                    cameraPosition.target.latitude,
                    cameraPosition.target.longitude);
                zone3.distance = calculateDistance(
                    zone3.latitude!,
                    zone3.longitude,
                    cameraPosition.target.latitude,
                    cameraPosition.target.longitude); */

                // update the ui with the address

                zoneList!.addAll(<Zone>{zone1, zone2, zone3, zone4, zone5});
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

                zoneList!.sort(((a, b) => a.distance!.compareTo(b.distance!)));

                textController.text = zoneList![0].name.toString() +
                    ':' +
                    zoneList![0].distance.toString() +
                    '\n' +
                    zoneList![1].name.toString() +
                    ':' +
                    zoneList![1].distance.toString();
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20,
            left: 10,
            right: 10,
            height: 80,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 3,
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
            bottom: 24,
            left: 24,
            right: 24,
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
