class Bus {
  String id;
  String lineId;

  Bus({this.id, this.lineId});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return new Bus(
        id: json['id'].toString(),
        lineId: json['line_id'].toString());
  }

  @override
  String toString() {
    return lineId + " id: " + id + "\n";
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
