class Line {
  String id;
  String routeName;
  int startStationId;
  String startStationName;
  int endStationId;
  String endStationName;

  Line({this.id, this.routeName, this.startStationId, this.startStationName, this.endStationId, this.endStationName});

  factory Line.fromJson(Map<String, dynamic> json) {
    return new Line(
      endStationId: json['endStationId'],
      endStationName: json['endStationName'],
      id: json['id'].toString(),
      routeName: json['routeName'],
      startStationId: json['startStationId'],
      startStationName: json['startStationName'],
    );
  }

  @override
  String toString() {
    return id + ' ' + routeName + ' ' + startStationId.toString() + ' ' + startStationName + ' ' + endStationId.toString() + ' ' + endStationName +  "\n";
  }
}



class PostLineList {
  final List<Line> lineList;

  PostLineList({
    this.lineList,
  });

  factory PostLineList.fromJson(List<dynamic> parsedJson) {
    List<Line> lineListTemp = new List<Line>();

    for (int i = 0; i < parsedJson.length; i++) {
      lineListTemp.add(Line.fromJson(parsedJson.elementAt(i)));
    }

    return new PostLineList(
        lineList: lineListTemp,
    );
  }
}
