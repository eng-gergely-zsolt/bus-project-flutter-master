class Entry{
  int stationId;
  int stationNr;

  Entry({this.stationId,this.stationNr});

  factory Entry.fromJson(Map<String, dynamic> json){
    return new Entry(
        stationId: json['StationID'],
        stationNr: json['StationNr']
    );
  }

  @override
  String toString() {
    return stationId.toString()+"  "+stationNr.toString();
  }
}



class Line{
  String lineId;
  List<Entry> stationList;

  Line({this.lineId,this.stationList});

  factory Line.fromJson(Map<String, dynamic> json){
    List<Entry> vEntryList = new List<Entry>();
    for(int i=0;i<json['Stations'].length;i++){
      vEntryList.add(Entry.fromJson(json['Stations'].elementAt(i)));
    }
    return new Line(
        lineId: json['LineID'],
        stationList: vEntryList
    );
  }

  @override
  String toString() {
    return lineId.toString()+"  "+stationList.toString();
  }
}



class PostLineList {
  final List<Line> lineList;

  PostLineList({
    this.lineList,
  });


  factory PostLineList.fromJson(List<dynamic> parsedJson) {
    List<Line> vLineList = new List<Line>();
    for(int i=0;i<parsedJson.length;i++){
      vLineList.add(Line.fromJson(parsedJson.elementAt(i)));
    }

    return new PostLineList(
      lineList: vLineList,
    );
  }

}