import 'package:flutter/material.dart';
import 'package:lokaluser/assistants/request_assistant.dart';
import 'package:lokaluser/global/map_key.dart';
import 'package:lokaluser/models/nearby_location.dart';
import 'package:lokaluser/models/predicted_places.dart';
import 'package:lokaluser/widgets/place_nearby_title.dart';
import 'package:lokaluser/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  final String? orgOrDes;
  final double? lat;
  final double? long;
  SearchPlacesScreen({this.orgOrDes, this.lat, this. long});

  @override
  _SearchPlacesScreenState createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];
  List<NearbyLocation> nearbyLocationList = [];





  void findNearBySearch()async{
    String urlNearbyLocationSearch =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${widget.lat}, ${widget.long}&radius=300&key=AIzaSyCNUi_diHn9j-5e7qiZsJyzX-OCnDVFEcY";
    // var nearbyLocationSearch = await RequestAssistant.receiveRequest(urlNearbyLocationSearch);

    try{
      var responseNearBySearch =
      await RequestAssistant.receiveRequest(urlNearbyLocationSearch);
      if (responseNearBySearch["status"] == "OK") {
        var nearByPlaces = responseNearBySearch["results"];

        var nearByLocationList = (nearByPlaces as List)
            .map((jsonData) => NearbyLocation.fromJson(jsonData))
            .toList();

        setState(() {
          nearByLocationList.removeAt(0);
          //nearByLocationList.removeLast();
          nearbyLocationList = nearByLocationList;
        });
      }
      else {
        setState(() {
          placesPredictedList.clear();
        });
      }
    }
    catch(e){
      print(e);
    }

  }

  void findPlaceAutoCompleteSearch(String inputText) async {

    if (inputText.length > 0) //2 or more than 2 input characters

    {
      placesPredictedList = [];
      //  String urlAutoCompleteSearch = 'images/destination.json';
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:IQ";
      //    "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:IQ";

      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch ==
          "Error Occurred, Failed. No Response.") {
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    } else {
      setState(() {
        placesPredictedList.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    findNearBySearch();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            //search place ui
            Container(
             // height: 160,
              decoration: const BoxDecoration(
                color: Colors.black54,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 25.0),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.grey,
                          ),
                        ),
                        const Center(
                          child: Text(
                            "Search & Set DropOff Location",
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.adjust_sharp,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (valueTyped) {
                                findPlaceAutoCompleteSearch(valueTyped);
                              },
                              decoration: const InputDecoration(
                                hintText: "search here...",
                                fillColor: Colors.white54,
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //display place predictions result
            if (placesPredictedList.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: placesPredictedList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PlacePredictionTileDesign(
                      predictedPlaces: placesPredictedList[index],
                      orgOrDes: widget.orgOrDes,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 1,
                      color: Colors.white,
                      thickness: 1,
                    );
                  },
                ),
              )
            else if (nearbyLocationList.isNotEmpty)

              Expanded(
                child: ListView.separated(


                  itemCount: nearbyLocationList.length,
                //  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PlaceNearbyTitle(
                      nearbyPleaces: nearbyLocationList[index],
                      orgOrDes: widget.orgOrDes,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 1,
                      color: Colors.white,
                      thickness: 1,
                    );
                  },
                ),
              )

            else
              const Padding(
                padding: EdgeInsets.only(top: 28.0),
                child: Text('type to search',
                    style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
