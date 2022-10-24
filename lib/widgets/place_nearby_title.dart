import 'package:flutter/material.dart';
import 'package:lokaluser/models/nearby_location.dart';
import 'package:lokaluser/models/predicted_places.dart';
import 'package:lokaluser/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

import '../InfoHandler/app_info.dart';
import '../assistants/request_assistant.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import '../models/directions.dart';

class PlaceNearbyTitle extends StatefulWidget {
  final NearbyLocation? nearbyPleaces;
  final String? orgOrDes;

  PlaceNearbyTitle({this.nearbyPleaces, this.orgOrDes});

  @override
  State<PlaceNearbyTitle> createState() => _PlaceNearbyTitleState();
}

class _PlaceNearbyTitleState extends State<PlaceNearbyTitle> {
  getPlaceDirectionDetails(String? placeId, String? orgOrDes, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => Center(
        child: ProgressDialog(
          message: "Setting Up Drof-Off, Please wait...",
        ),
      ),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if (responseApi == "Error Occurred, Failed. No Response.") {
      return;
    }

    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      if (orgOrDes == 'origin') {
        /* Directions? directions2 = Directions();
        directions2 = null;
        Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions2!);
*/
        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(directions);

        // Navigator.pop(context, "");
        //  Provider.of<AppInfo>(context).userDropOffLocation!.locationName = '';
        /*   Directions? directions2 = Directions();

   */
      } else {
        Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);
      }
      setState(() {
        gUserDropOffAddress = directions.locationName!;
      });
      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.nearbyPleaces!.place_id, widget.orgOrDes!, context);

        //else()
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            const Icon(
              Icons.add_location,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 14.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    widget.nearbyPleaces!.name!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),

                  const SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
