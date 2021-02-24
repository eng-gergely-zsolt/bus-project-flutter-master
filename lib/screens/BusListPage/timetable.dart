import 'package:bus_project/models/station.dart';
import 'package:bus_project/models/timetable.dart';
import 'package:bus_project/screens/Shared/list.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class TimetableScreen extends StatelessWidget {
  final String busId;
  int firstId = -1;
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  List<Timetable> actualTimetable1;
  List<Timetable> actualTimetable2;

  TimetableScreen([this.busId]);



  @override
  Widget build(BuildContext context) {
    currentContext = context;
    actualTimetable1 = new List<Timetable>.from(timetableListGlobal);
    actualTimetable1.retainWhere((Timetable t) {
      if (t.lineId == busId) {
        return true;
      } else {
        return false;
      }
    });


    firstId = actualTimetable1[0].stationID;


    actualTimetable2 = new List<Timetable>.from(actualTimetable1);
    actualTimetable1.retainWhere((Timetable t) {
      if (t.stationID == firstId) {
        return true;
      } else {
        return false;
      }
    });
    actualTimetable2.retainWhere((Timetable t) {
      if (t.stationID != firstId) {
        return true;
      } else {
        return false;
      }
    });


    List<Widget> list1 = List();
    actualTimetable1.forEach((Timetable t){
      list1.add(new Padding(padding: new EdgeInsets.all(20.0),
          child: new Text(
              t.startTime,
              style: new TextStyle(fontSize: 25.0)
          )));
    });
    List<Widget> list2 = List();
    actualTimetable2.forEach((Timetable t){
      list2.add(new Padding(padding: new EdgeInsets.all(20.0),
          child: new Text(
              t.startTime,
              style: new TextStyle(fontSize: 25.0)
          )));
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(
              AppLocalizations.of(context).translate('timetable_title') +
                  busId +
                  " " +
                  dateFormat.format(DateTime.now())),
        ),
        body: //CustomScrollView( slivers: <Widget>[
        Row(
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(gStationList.firstWhere((Station s) {
                      // ignore: unrelated_type_equality_checks
                      if (s.id == actualTimetable1.elementAt(0).stationID)
                        return true;
                      return false;
                    }).stationName,
                        style: new TextStyle(fontSize: 20.0)),
                    new Container(
                        height: 500.0,
                        width: 180.0,
                        child:
                        CustomScrollView(
                            slivers: <Widget>[SliverList(delegate: new SliverChildListDelegate(list1))])),
                  ]),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(gStationList.firstWhere((Station s) {
                      // ignore: unrelated_type_equality_checks
                      if (s.id == actualTimetable2.elementAt(0).stationID)
                        return true;
                      return false;
                    }).stationName,
                        style: new TextStyle(fontSize: 20.0)),
                    new Container(
                        height: 500.0,
                        width: 180.0,
                        child:
                        CustomScrollView(
                            slivers: <Widget>[SliverList(delegate: new SliverChildListDelegate(list2))])),
                  ]),
            ]));
  }
}
