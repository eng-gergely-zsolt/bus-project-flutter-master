class Entry{
  int stationId;
  int direction;
  int orderNumber;

  Entry({this.stationId, this.direction, this.orderNumber});

  factory Entry.fromJson(Map<String, dynamic> json){
    return new Entry(
        stationId: json['station_id'],
        direction: json['direction'],
        orderNumber: json['order_number']
    );
  }

  @override
  String toString() {
    return stationId.toString() + ' '  + direction.toString() + ' ' + orderNumber.toString();
  }
}



class StationOnLine{
  String lineId;
  List<Entry> lineData;

  StationOnLine({this.lineId, this.lineData});

  factory StationOnLine.fromJson(Map<String, dynamic> json){
    List<Entry> vEntryList = new List<Entry>();
    for(int i = 0; i < json['LineData'].length; ++i){
      vEntryList.add(Entry.fromJson(json['LineData'].elementAt(i)));
    }
    return new StationOnLine(
        lineId: json['line_id'],
        lineData: vEntryList
    );
  }

  @override
  String toString() {
    return lineId.toString() + "  " + lineData.toString();
  }
}



class PostStationOnLineList {
  final List<StationOnLine> stationOnlineList;

  PostStationOnLineList(this.stationOnlineList);


  factory PostStationOnLineList.fromJson(List<dynamic> parsedJson) {
    List<StationOnLine> vLineList = new List<StationOnLine>();
    for(int i = 0; i < parsedJson.length; ++i){
      vLineList.add(StationOnLine.fromJson(parsedJson.elementAt(i)));
    }

    return new PostStationOnLineList(vLineList);
  }
}