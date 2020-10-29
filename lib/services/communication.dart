import 'dart:async';
import 'dart:convert';
import 'package:bus_project/models/bus.dart';
import 'package:bus_project/models/trace.dart';
import 'package:http/http.dart' as http;
import 'package:bus_project/models/arrival_time.dart';
import 'package:bus_project/models/bus_data.dart';
import 'package:bus_project/models/line.dart';
import 'package:bus_project/models/station.dart';
import 'package:bus_project/models/timetable.dart';


Future<BusInformationListPost> getBusInformationList() async {
  final response = await http.get('http://192.168.1.2:8080/WCFService/Service1/web/GetBusInformationList');
  // final response = await http.get('http://192.168.0.220:8080/WCFService/Service1/web/GetBusInformationList');
  // final response = await http.get("http://193.226.0.198:5210/WCFService/Service1/web/GetBusInformation");

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    var temp = BusInformationListPost.fromJson(json.decode(response.body));
//    temp.busList.forEach((f) => print(f.toString()));
    return temp;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load getBusInformation post!');
  }
}


Future<BusList> getBusList() async {
  final response = await http.get('http://192.168.1.2:8080/WCFService/Service1/web/GetBusList');
  // final response = await http.get('http://192.168.0.220:8080/WCFService/Service1/web/GetBusList');
  // final response = await http.get("http://193.226.0.198:5210/WCFService/Service1/web/GetBusesList");

  if (response.statusCode == 200) {
    var temp = BusList.fromJson(json.decode(response.body));
//    temp.vBusList.forEach((f) => print(f.toString()));
    return temp;
  } else {
    throw Exception('Failed to load getBusList post!');
  }
}


Future<PostLineList> getLineList() async {
  final response = await http.get('http://192.168.1.2:8080/WCFService/Service1/web/GetLineList');
  // final response = await http.get('http://192.168.0.220:8080/WCFService/Service1/web/GetLineList');
  // final response = await http.get("http://193.226.0.198:5210/WCFService/Service1/web/GetLinesList");

  if (response.statusCode == 200) {
    var temp = PostLineList.fromJson(json.decode(response.body));
//    temp.lineList.forEach((f) => print(f.toString()));
    return temp;
  } else {
    throw Exception('Failed to load getLineList post!');
  }
}


Future<PostStationList> getStationList() async {
  final response = await http.get('http://192.168.1.2:8080/WCFService/Service1/web/GetStationList');
  // final response = await http.get('http://192.168.0.220:8080/WCFService/Service1/web/GetStationList');
  // final response = await http.get("http://193.226.0.198:5210/WCFService/Service1/web/GetStationList");

  if (response.statusCode == 200) {
    var temp = PostStationList.fromJson(json.decode(response.body));
//    temp.vStationList.forEach((f) => print(f.toString()));
    return temp;
  } else {
    throw Exception('Failed to load getStationList post!');
  }
}


Future<PostArrivalTimeList> getArrivalTimeList(int stationID) async {
  // "http://192.168.1.7:8080/WCFService/Service1/web/GetArrivalTimeList?StationID="
  // "http://192.168.0.220:8080/WCFService/Service1/web/GetArrivalTimeList?StationID="
  // "http://193.226.0.198:5210/WCFService/Service1/web/GetTimeList?StationID="
  final response =
  await http.get("http://192.168.1.2:8080/WCFService/Service1/web/GetArrivalTimeList?StationID=" + stationID.toString());

  if (response.statusCode == 200) {
    var temp = PostArrivalTimeList.fromJson(json.decode(response.body));
//    temp.arrivalTimeList.forEach((f) => print(f.toString()));
    return temp;
  } else {
    throw Exception('Failed to load getTimeList post!');
  }
}


Future<PostTimetableList> getTimetableList() async {
  final response = await http.get('http://192.168.1.2:8080/WCFService/Service1/web/GetTimetableList');
  // final response = await http.get('http://192.168.0.220:8080/WCFService/Service1/web/GetTimetableList');
  // final response = await http.get("http://193.226.0.198:5210/WCFService/Service1/web/GetTimetable");

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var temp = PostTimetableList.fromJson(json.decode(response.body));
    //temp.TimetableList.forEach((f)=> print(f.toString()));
    return temp;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load getTimetable post!');
  }
}


Future<PostBusTraceList> getBusTraceList() async {
  final response = await http.get('http://192.168.1.2:8080/WCFService/Service1/web/GetBusTraceList');
  // final response = await http.get('http://192.168.0.220:8080/WCFService/Service1/web/GetBusTraceList');
  // final response = await http.get("http://193.226.0.198:5210/WCFService/Service1/web/GetTracesList");

  if (response.statusCode == 200) {
    var temp = PostBusTraceList.fromJson(json.decode(response.body));
//    temp.traceList.forEach((f) => print(f.toString()));
    return temp;
  } else {
    throw Exception('Failed to load getBusTraceList post!');
  }
}


void postBusInformation(Map body) async {
  // "http://192.168.1.7:8080/WCFService/Service1/web/PostBusInformation"
  // "http://192.168.0.220:8080/WCFService/Service1/web/PostBusInformation"
  // 'http://193.226.0.198:5210/WCFService/Service1/web/PostBusInformation'
  return http.post("http://192.168.1.2:8080/WCFService/Service1/web/PostBusInformation",
      headers: {"Content-Type": "application/json"},
      body: json.encode(body)).then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while posting postBusInformation data!");
    }

    return;
  });
}


void postBusInformationTest(Map body) async {
  // "http://192.168.1.7:8080/WCFService/Service1/web/PostBusMeasurement"
  // "http://192.168.0.220:8080/WCFService/Service1/web/PostBusMeasurement"
  // "http://193.226.0.198:5210/WCFService/Service1/web/PostBusMeasurement"
  return http.post("http://192.168.1.2:8080/WCFService/Service1/web/PostBusMeasurement",
      headers: {"Content-Type": "application/json"},
      body: json.encode(body)).then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while posting postBusInformationTest data!");
    }

    return;
  });
}


Future<DateTime> synchronization() async {
  final response = await http.get('http://192.168.1.2:8080/WCFService/Service1/web/Synchronization');
  // final response = await http.get('http://192.168.0.220:8080/WCFService/Service1/web/Synchronization');
  // final response = await http.get('http://193.226.0.198:5210/WCFService/Service1/web/Syncronization');

  if (response.statusCode == 200) {
    DateTime actualTime = DateTime.parse(json.decode(response.body) as String);
//    print(actualTime.toString());
    return actualTime;
  } else {
    throw Exception('Failed to load synchronization post!');
  }
}