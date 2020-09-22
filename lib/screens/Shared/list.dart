import 'package:bus_project/models/bus.dart';
import 'package:bus_project/models/trace.dart';
import 'package:bus_project/services/ActivityRecognition.dart';
import 'package:bus_project/services/GPS.dart';
import 'package:flutter/cupertino.dart';
import 'package:bus_project/models/arrival_time.dart';
import 'package:bus_project/models/bus_data.dart';
import 'package:bus_project/models/line.dart';
import 'package:bus_project/models/station.dart';
import 'package:bus_project/models/timetable.dart';

List<BusInformation> bus_list;
List<Bus> businfo_list;
List<Station> gStationList;

List<Line> lineList;
List<Trace> traceList;

List<ArrivalTime> arrivaltime_list;
List<Timetable> gTimetable;
//double range = 0.15;
double range = 150;
int bus_list_size;
BuildContext currentContext;
ActivityRecognition DrivingDetector = ActivityRecognition();
GPS GeoPosition = GPS();

int next;
Line actualLine;
Entry actualStation;
Entry nextStation;
Stopwatch stopwatch;

Duration ServerClientDifference = null;
String stationText = "No stations nearby";
bool nearStation = false;
String MyBusId;
