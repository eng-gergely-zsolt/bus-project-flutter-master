class CourseData {
  String courseId;
  String lineId;
  int direction;
  double latitude;
  double longitude;
  String measurementTimestamp;

  CourseData({
    this.courseId,
    this.lineId,
    this.direction,
    this.latitude,
    this.longitude,
    this.measurementTimestamp,
    // this.pointsNearby
  });

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return new CourseData(
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
    return
        " Latitude: " + latitude.toString() +
        " Longitude: " + longitude.toString();
  }
}



class BusDataListPost {
  final List<CourseData> busList;

  BusDataListPost({
    this.busList,
  });


  factory BusDataListPost.fromJson(List<dynamic> parsedJson) {
    List<CourseData> buses = new List<CourseData>();
    for (int i = 0; i < parsedJson.length; i++) {
      buses.add(CourseData.fromJson(parsedJson.elementAt(i)));
    }


    return new BusDataListPost(
      busList: buses,
    );
  }
}