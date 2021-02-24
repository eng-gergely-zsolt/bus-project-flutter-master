import 'package:bus_project/models/bus.dart';
import 'package:bus_project/models/line.dart';
import 'package:bus_project/models/trace.dart';
import 'package:bus_project/models/user_on_bus.dart';
import 'package:bus_project/services/ActivityRecognition.dart';
import 'package:bus_project/services/GPS.dart';
import 'package:flutter/cupertino.dart';
import 'package:bus_project/models/arrival_time.dart';
import 'package:bus_project/models/bus_data.dart';
import 'package:bus_project/models/station_on_line.dart';
import 'package:bus_project/models/station.dart';
import 'package:bus_project/models/timetable.dart';


List<Station> gStationList;
List<Line> lineListGlobal;
var userOnBus = new UserOnBus(-1, '-1', 0, 0);
List<String> routeNames = new List();
List<String> routeNamesMap = new List();

List<BusData> gBusList;
// List<Bus> gBusDataList;
List<StationOnLine> stationOnLineListGlobal;
List<Trace> gTraceList;
List<ArrivalTime> gArrivalTimeList;
List<Timetable> timetableListGlobal;

int next;
int gBusListSize;
double gRangeInKilometer = 1;
String gMyBusId;
String gStationText = "No stations nearby";
bool gNearStation = false;

BuildContext currentContext;
ActivityRecognition gDrivingDetector = ActivityRecognition();
GPS gGeoPosition = GPS();
Duration gServerClientDifference;

StationOnLine actualLine;
Entry actualStation;
Entry nextStation;
Stopwatch stopwatch;



