class Bus {
  String busId;
  String busName;

  Bus({this.busId, this.busName});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return new Bus(
        busId: json['BusId'].toString(),
        busName: json['BusName'].toString());
  }

  @override
  String toString() {
    return busName +
        " Id: " +
        busId +
        "\n";
  }
}



class BusList {
  final List<Bus> vBusList;

  BusList({
    this.vBusList,
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

  factory BusList.fromJson(List<dynamic> parsedJson) {
    List<Bus> busInfo = new List<Bus>();
    for (int i = 0; i < parsedJson.length; i++) {
      busInfo.add(Bus.fromJson(parsedJson.elementAt(i)));
    }

    //buses = parsedJson.map((i) => Bus.fromJson(i)).toList();

    return new BusList(
      vBusList: busInfo,
    );
  }
}
