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


List<BusInformation> gBusList;
List<Bus> gBusDataList;
List<Station> gStationList;
List<Line> gLineList;
List<Trace> gTraceList;
List<ArrivalTime> gArrivalTimeList;
List<Timetable> gTimetable;

int next;
int gBusListSize;
double range = 150;
String gStationText = "No stations nearby";
bool gNearStation = false;
String gMyBusId;

BuildContext currentContext;
ActivityRecognition gDrivingDetector = ActivityRecognition();
GPS gGeoPosition = GPS();
Duration gServerClientDifference;

Line actualLine;
Entry actualStation;
Entry nextStation;
Stopwatch stopwatch;



