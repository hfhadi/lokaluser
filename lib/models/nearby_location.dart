class NearbyLocation
{
  String? place_id;
  String? name;
  String? icon;
  double? lat;
  double? long;

  NearbyLocation({
    this.place_id,
    this.name,
    this.icon,
    this.lat,
    this.long
  });

  NearbyLocation.fromJson(Map<String, dynamic> jsonData)
  {
    place_id = jsonData["place_id"];
    name = jsonData["name"];
    icon = jsonData["icon"];
    lat=jsonData["geometry"]["location"]["lat"];
    long=jsonData["geometry"]["location"]["lng"];
  }
}