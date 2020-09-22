class ArrivalTime {
  String busID;
  String timeString;
  String requiredTime;

  ArrivalTime({this.busID, this.timeString, this.requiredTime});

  factory ArrivalTime.fromJson(Map<String, dynamic> json) {
    return new ArrivalTime(
        busID: json['busID'].toString(),
        timeString: json['TheTimeString'].toString(),
        requiredTime: json['requiredTime'].toString());
  }

  @override
  String toString() {
    return busID + " will arrive in : " + timeString + "\n";
  }
}

class PostArrivalTimeList {
  final List<ArrivalTime> arrivalTimeList;

  PostArrivalTimeList({
    this.arrivalTimeList,
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

  factory PostArrivalTimeList.fromJson(List<dynamic> parsedJson) {
    List<ArrivalTime> vArrivalTimeList = new List<ArrivalTime>();
    for (int i = 0; i < parsedJson.length; i++) {
      vArrivalTimeList.add(ArrivalTime.fromJson(parsedJson.elementAt(i)));
    }

    //buses = parsedJson.map((i) => Bus.fromJson(i)).toList();

    return new PostArrivalTimeList(
      arrivalTimeList: vArrivalTimeList,
    );
  }
}
