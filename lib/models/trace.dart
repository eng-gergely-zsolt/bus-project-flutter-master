class Point{
  double latitude;
  double longitude;
  int direction;
  int orderNumber;

  Point({this.latitude, this.longitude, this.direction, this.orderNumber});

  factory Point.fromJson(Map<String, dynamic> json){
    return new Point(
        latitude: json['latitude'],
        longitude: json['longitude'],
        direction: json['direction'],
        orderNumber: json['order_number']
    );
  }

  @override
  String toString() {
    return longitude.toString() + "  " + latitude.toString();
  }
}



class Trace{
  String lineId;
  List<Point> pointList;

  Trace({this.lineId,this.pointList});

  factory Trace.fromJson(Map<String, dynamic> json){
    List<Point> vPointList = new List<Point>();
    for(int i=0;i<json['LineTraceData'].length;i++){
      vPointList.add(Point.fromJson(json['LineTraceData'].elementAt(i)));
    }
    return new Trace(
        lineId: json['line_id'],
        pointList: vPointList
    );
  }

  @override
  String toString() {
    return lineId.toString()+"  "+pointList.toString();
  }
}





class PostLineTraceList {
  final List<Trace> traceList;

  PostLineTraceList({
    this.traceList,
  });


  factory PostLineTraceList.fromJson(List<dynamic> parsedJson) {

    List<Trace> vTraceList = new List<Trace>();
    for(int i=0;i<parsedJson.length;i++){
      vTraceList.add(Trace.fromJson(parsedJson.elementAt(i)));
    }

    //buses = parsedJson.map((i) => Bus.fromJson(i)).toList();

    return new PostLineTraceList(
      traceList: vTraceList,
    );
  }
}