class BusData {
  String busId;
  String courseId;
  String lineId;
  int direction;
  double latitude;
  double longitude;
  String measurementTimestamp;
  int pointsNearby = null;

  BusData({
    this.busId,
    this.courseId,
    this.lineId,
    this.direction,
    this.latitude,
    this.longitude,
    this.measurementTimestamp,
    // this.pointsNearby
  });

  factory BusData.fromJson(Map<String, dynamic> json) {
    return new BusData(
        busId: json['BusId'].toString(),
        courseId: json['CourseId'].toString(),
        lineId: json['LineId'].toString(),
        direction: json['Direction'],
        latitude: json['Latitude'].toDouble(),
        longitude: json['Longitude'].toDouble(),
        measurementTimestamp: json['Measurement_Timestamp'].toString(),
        // pointsNearby: json['Points_nearby']
    );
  }

  @override
  String toString() {
    return busId +
        " Latitude: " + latitude.toString() +
        " Longitude: " + longitude.toString();
  }
}



class BusDataListPost {
  final List<BusData> busList;

  BusDataListPost({
    this.busList,
  });


  factory BusDataListPost.fromJson(List<dynamic> parsedJson) {
    List<BusData> buses = new List<BusData>();
    for (int i = 0; i < parsedJson.length; i++) {
      buses.add(BusData.fromJson(parsedJson.elementAt(i)));
    }


    return new BusDataListPost(
      busList: buses,
    );
  }
}
