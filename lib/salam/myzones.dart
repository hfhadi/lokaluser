import 'package:flutter/material.dart';
import 'package:google_maps_controller/google_maps_controller.dart';
import 'dart:math';
import 'package:google_maps_utils/google_maps_utils.dart' as utils;
import 'package:lokaluser/salam/zone.dart';
import 'package:xml/xml.dart';

class MyZones {
  var polygonSet = <Polygon>{};

  List<Point> pointsOfPolygonArea = [];
  List<List<Point>> allePolygonArea = [];

  late XmlDocument document;

  late Iterable<XmlElement> titlesOfPlacemark;
  final List<String> placemarkList = [];

  late Iterable<XmlElement> titlesOfCoordinates;
  final List<String> pointsListOfZones = [];

  late Iterable<XmlElement> titlesOfColors;
  final List<String> colorsList = [];
  final List<String> colorsList2 = [];
  final Map<String, Object> zonesMap = {};

  getParseXMLData() {
    List<LatLng> listOfLatlngPoints = [];

    document = XmlDocument.parse(MyXmlZone.xmlZone);

    titlesOfPlacemark = document.findAllElements('Placemark');

    titlesOfCoordinates = document.findAllElements('coordinates');

    titlesOfColors = document.findAllElements('color');

    titlesOfColors.map((e) => e.text)
        //.where((element) => element.contains('color'))
        .forEach((element) {
      colorsList.add(element);
    });

    for (var i = 0; i < colorsList.length; i = i + 4) {
      colorsList2.add(colorsList[i]);
    }

    titlesOfPlacemark.map((e) => e.text).forEach((element) {
      //print(element);
      var searchString = '#';
      var index = element.indexOf(searchString);
      // print(element.substring(0, index - 7).trim());
      placemarkList.add(element.substring(0, index - 7).trim());
    });

    titlesOfCoordinates.map((e) => e.text).forEach((element) {
      // print(element);
      pointsListOfZones.add(element.replaceAll(',0', ''));

      /*  var searchString = '4';
    var index = element.indexOf(searchString);
    // print(index);
    myZones.add(element.substring(0, index - 7).trim()); */
    });

    var index = 0;

    for (String element in pointsListOfZones) {
      var removeLines = element.replaceAll('\n', '');
      // var f = g.replaceAll(' ', '');
      // f.splitMapJoin(pattern);
      // print((5 - 8) * 3);
      var removeSpeaces = removeLines.replaceAll('      ', '').trimLeft();
      var splitStrings = removeSpeaces.split('  ');

      splitStrings.forEach((element) {
        var allZonesPointAfterRemovingSplit = element.split(',');
        // j.sort((a, b) => a.compareTo(b));
        double lat = double.parse(allZonesPointAfterRemovingSplit[1]);
        double long = double.parse(allZonesPointAfterRemovingSplit[0]);
        Point pointOfPolygon = Point(lat, long);
        LatLng lngOfPolygon = LatLng(lat, long);

        pointsOfPolygonArea.add(pointOfPolygon);
        listOfLatlngPoints.add(lngOfPolygon);
      });

      // print('center point ${calculateCenter(listOfLatlngPoints)}');
      listOfLatlngPoints.clear();
      //listOfLatlngPoints.clear();
      //print(pointsOfPolygonArea);
      zonesMap.addAll({placemarkList[index]: pointsOfPolygonArea});

      allePolygonArea.add(pointsOfPolygonArea);

      /* print(pointsOfPolygonArea);

      print('-----');*/
      pointsOfPolygonArea = [];
      index++;
      // print('-----');
    }
    zonesMap.forEach((key, value) {
      // print(key);
    });
  }

  LatLng calculateCenter(List<LatLng> points) {
    var longitudes = points.map((i) => i.longitude).toList();
    var latitudes = points.map((i) => i.latitude).toList();

    latitudes.sort();
    longitudes.sort();

    var lowX = latitudes.first;
    var highX = latitudes.last;
    var lowy = longitudes.first;
    var highy = longitudes.last;

    var centerX = lowX + ((highX - lowX) / 2);
    var centerY = lowy + ((highy - lowy) / 2);

    return LatLng(centerX, centerY);
  }

  Set<Polygon> myPolygon() {
    //Image img = Image.asset('images/car_logo.png');
    //final file = File('images/zone.xml');
    getParseXMLData();

    //   print(allePolygonArea.length);
    // Point m = Point(32.583500385744536, 44.01978771375997);

    // print(getCurrentNameOfAreaOfdriverPosition(zonesMap, m));
    /*ZonesName.addAll({myZones2[0]: pointsOfPolygonArea[0]});
  print(pointsOfPolygonArea);*/
    //getAllPolygones(allePolygonArea);
    //print(allePolygonArea);

    List<LatLng> polygonLatLong = [];
    int index = 0;
    List<String> zonesNameList = [];

    zonesMap.forEach((key, value) {
      zonesNameList.add(key);
    });

    for (List<Point> element in allePolygonArea) {
      for (var point in element) {
        polygonLatLong.add(LatLng(point.x as double, point.y as double));
      }
      String name = zonesNameList[index];

      polygonSet.add(
        Polygon(
            onTap: () => print(name),
            polygonId: PolygonId(name),
            points: polygonLatLong,
            strokeWidth: 2,
            strokeColor: Colors.green,
            //   fillColor: Colors.grey.withOpacity(0.3)),
            //  fillColor: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.7)),
            fillColor: Color(int.parse(colorsList2[index], radix: 17)).withOpacity(0.3)),
      );
      if (index < colorsList2.length - 1) {
        index++;
      }

      polygonLatLong = [];
    }
    // print(index);
    // print(colorsList2.length);
    // print(colorsList2);
    return polygonSet;
  }

  getZoneNameByCameraPosition(CameraPosition cameraPosition) {
    getParseXMLData();

    Point point = Point(cameraPosition.target.latitude, cameraPosition.target.longitude);

    return (getCurrentNameOfAreaOfdriverPosition(zonesMap, point));
  }

  getZoneNameByPoint(Point userPoint) {
    getParseXMLData();

    Point point = Point(userPoint.x, userPoint.y);

    return (getCurrentNameOfAreaOfdriverPosition(zonesMap, point));
  }

  String getCurrentNameOfAreaOfdriverPosition(Map<String, Object> zonesMap, Point point) {
    String zoneName = '';
    zonesMap.forEach((key, value) {
      List<Point> zonePoints = value as List<Point>;

      bool contains = utils.PolyUtils.containsLocationPoly(point, zonePoints);
      if (contains) {
        // print('salam is inside $key');
        zoneName = key;
      }
    });
    return zoneName;
  }
}
