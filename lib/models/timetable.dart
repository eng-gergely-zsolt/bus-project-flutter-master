class Timetable {
  String busNr;
  String startTime;
  int stationID;

  Timetable({this.busNr, this.startTime, this.stationID});

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return new Timetable(
        busNr: json['BusNr'],
        stationID: json['StationId'],
        startTime: json['StartTime'].toString());
  }

  @override
  String toString() {
    return busNr.toString() + " will start : " + startTime + " from " + stationID.toString() + "\n";
  }
}

class PostTimetableList {
  final List<Timetable> timetableList;

  PostTimetableList({
    this.timetableList,
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

  factory PostTimetableList.fromJson(List<dynamic> parsedJson) {
    List<Timetable> vTimetableList = new List<Timetable>();
    for (int i = 0; i < parsedJson.length; i++) {
      vTimetableList.add(Timetable.fromJson(parsedJson.elementAt(i)));
    }

    //buses = parsedJson.map((i) => Bus.fromJson(i)).toList();

    return new PostTimetableList(
      timetableList: vTimetableList,
    );
  }
}
