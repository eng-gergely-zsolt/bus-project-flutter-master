class Station {
  String stationId;
  String stationName;
  double latitude;
  double longitude;

  Station({this.stationId, this.stationName, this.latitude, this.longitude});

  factory Station.fromJson(Map<String, dynamic> json) {
    return new Station(
        stationId: json['StationId'].toString(),
        stationName: json['StationName'].toString(),
        latitude: json['Latitude'].toDouble(),
        longitude: json['Longitude'].toDouble());
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
