class Point{
  double latitude;
  double longitude;

  Point({this.latitude, this.longitude});

  factory Point.fromJson(Map<String, dynamic> json){
    return new Point(
        latitude: json['Latitude'],
        longitude: json['Longitude']
    );
  }

  @override
  String toString() {
    return longitude.toString()+"  "+latitude.toString();
  }
}



class Trace{
  String lineId;
  List<Point> pointList;

  Trace({this.lineId,this.pointList});

  factory Trace.fromJson(Map<String, dynamic> json){
    List<Point> vPointList = new List<Point>();
    for(int i=0;i<json['Points'].length;i++){
      vPointList.add(Point.fromJson(json['Points'].elementAt(i)));
    }
    return new Trace(
        lineId: json['BusId'],
        pointList: vPointList
    );
  }

  @override
  String toString() {
    return lineId.toString()+"  "+pointList.toString();
  }
}





class PostBusTraceList {
  final List<Trace> traceList;

  PostBusTraceList({
    this.traceList,
  });


  factory PostBusTraceList.fromJson(List<dynamic> parsedJson) {

    List<Trace> vTraceList = new List<Trace>();
    for(int i=0;i<parsedJson.length;i++){
      vTraceList.add(Trace.fromJson(parsedJson.elementAt(i)));
    }

    //buses = parsedJson.map((i) => Bus.fromJson(i)).toList();

    return new PostBusTraceList(
      traceList: vTraceList,
    );
  }
}