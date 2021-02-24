class Station {
  String id;
  String stationName;
  double latitude;
  double longitude;

  Station({this.id, this.stationName, this.latitude, this.longitude});

  factory Station.fromJson(Map<String, dynamic> json) {
    return new Station(
        id: json['id'].toString(),
        stationName: json['station_name'].toString(),
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble());
  }

  @override
  String toString() {
    return stationName +
        " Latitude: " +
        latitude.toString() +
        " Longitude: " +
        longitude.toString() +
        "\n";
  }
}

class PostStationList {
  final List<Station> stationList;

  PostStationList({
    this.stationList,
  });

/*
  factory BusListPost.fromJson(Map<String, dynamic> json) {
    List<Bus> buses = new List<Bus>();
    //buses = json.map((i)=>Bus.fromJson(i)).toList();
    buses=json.map((i) => Bus.fromJson(i)).toList();
    return new BusListPost(
        BusList: buses
    );
  }*/

  factory PostStationList.fromJson(List<dynamic> parsedJson) {
    List<Station> vStationList = new List<Station>();
    for (int i = 0; i < parsedJson.length; i++) {
      vStationList.add(Station.fromJson(parsedJson.elementAt(i)));
    }

    //buses = parsedJson.map((i) => Bus.fromJson(i)).toList();

    return new PostStationList(
      stationList: vStationList,
    );
  }
}
