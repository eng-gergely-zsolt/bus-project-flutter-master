class BusInformation {
  String busId;
  double actualLatitude;
  double actualLongitude;
  String measurementTimestamp;
  int pointsNearby;

  BusInformation(
      {this.busId,
        this.actualLatitude,
        this.actualLongitude,
        this.measurementTimestamp,
        this.pointsNearby});

  factory BusInformation.fromJson(Map<String, dynamic> json) {
    return new BusInformation(
        busId: json['BusId'].toString(),
        actualLatitude: json['Actual_Latitude'].toDouble(),
        actualLongitude: json['Actual_Longitude'].toDouble(),
        measurementTimestamp: json['Measurement_Timestamp'].toString(),
        pointsNearby: json['Points_nearby']
    );
  }

  @override
  String toString() {
    return busId +
        " Latitude: " +
        actualLatitude.toString() +
        " Longitude: " +
        actualLongitude.toString();
  }
}



class BusInformationListPost {
  final List<BusInformation> busList;

  BusInformationListPost({
    this.busList,
  });


  factory BusInformationListPost.fromJson(List<dynamic> parsedJson) {
    List<BusInformation> buses = new List<BusInformation>();
    for (int i = 0; i < parsedJson.length; i++) {
      buses.add(BusInformation.fromJson(parsedJson.elementAt(i)));
    }


    return new BusInformationListPost(
      busList: buses,
    );
  }
}
