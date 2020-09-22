import 'package:background_fetch/background_fetch.dart';
import 'package:bus_project/models/bus_data.dart';
import 'package:bus_project/models/bus.dart';
import 'package:bus_project/models/line.dart';
import 'package:bus_project/screens/Shared/start.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:bus_project/services/AppPropertiesBLoC.dart';
import 'package:flutter/material.dart';
import 'package:bus_project/screens/Shared/list.dart';
import 'package:bus_project/screens/MapPage/maps.dart';
import 'package:bus_project/services/communication.dart';
import 'timetable.dart';

class Todo {
  String BusId;
  double Actual_Latitude;
  double Actual_Longitude;

  Todo(this.BusId, this.Actual_Latitude, this.Actual_Longitude);
}

class Buslist1 extends StatefulWidget {
  @override
  _BusListActionListener createState() => new _BusListActionListener();
}

class _BusListActionListener extends State<Buslist1> {
  //List<int> bus_name = list();
  //Map<int, String> _list_map = list_map();

  @override
  void initState() {
    super.initState();

    if (gBusDataList == null) {
      getBusList().then((val) => setState(() {
        gBusDataList = val.vBusList;
      }));
    }
    if (gBusList == null) {
      getBusInformationList().then((val) => setState(() {
        gBusList = val.busList;
      }));
    }


    if (gStationList == null) {
      getStationList().then((val) => setState(() {
        gStationList = val.stationList;
      }));

      print(gStationList);
      print('bus_list.dart, line 50');
    }


    if (gLineList == null) {
      getLineList().then((val) => setState(() {
        gLineList = val.lineList;

//        print(lineList);
//        print('bus_list.dart, line 51');
      }));
    }


    if (gTraceList == null) {
      getTraceList().then((val) => setState(() {
        gTraceList = val.traceList;

//        print(traceList[2]);
//        print('bus_list.dart, line 60');
      }));
    }


    if (gTimetable == null) {
      getTimetableList().then((val) => setState(() {
        gTimetable = val.timetableList;

//            print(timetable);
//            print('bus_list.dart, line 69');
      }));
    }


    if (gServerClientDifference == null) {
      synchronization().then((serverTime) {
//        print(serverTime);
        gServerClientDifference = DateTime.now()
            .difference(serverTime); //I guess this doesn't need refresh so...
//        print(ServerClientDifference);
      });}

    gGeoPosition.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return gBusDataList == null
        ? Scaffold(
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center,

                ///new
                children: <Widget>[CircularProgressIndicator()])))
        : ListView.builder(
      itemCount: gBusDataList.length,
      itemBuilder: (context, index) {
        Bus item = gBusDataList[index];
        return Dismissible(
          key: Key(item.busId),
          direction: DismissDirection.endToStart,
          confirmDismiss: (DismissDirection dir){
            if(dir == DismissDirection.endToStart){
//                    print("right swap");
              BusInformation bus =gBusList.firstWhere((x){
                return gBusDataList.elementAt(index).busId == x.busId;
              },orElse: () => null);
              if(bus != null) {
                Todo coords = Todo(
                    bus.busId,
                    bus.actualLatitude,
                    bus.actualLongitude);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Maps(coords),
                  ),
                );
              }
            }
          },
          background: Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(AppLocalizations.of(context).translate('bus_list_show_map')),//"See it on the map!"),
                Icon(Icons.map),
              ],
            ),
            //
            color: Colors.blue,
            alignment: Alignment.centerRight,
          ),
          child: ListTile(
            leading: new CircleAvatar(
                foregroundColor: Colors.white,
                backgroundColor: (item.busId == gMyBusId)?Colors.red:Colors.blue,
                child: new Text(gBusDataList.elementAt(index).busId)),
            title: Text(gBusDataList.elementAt(index).busName),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
//                    print("Rovid gomb nyomas");
              _startJourney(gBusDataList.elementAt(index).busId);
            },
            onLongPress: () {
//                    print("Hosszu gomb nyomas");
              if (gTimetable != null) {
                String busid = gBusDataList.elementAt(index).busId;
                if(gTimetable.firstWhere((o) => o.busNr == busid, orElse: () => null) != null)//singleWhere((o) => o.busNr == busid, orElse: () => null) != null)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimetableScreen(busid),
                    ),
                  );
              }
            },
          ),
        );
      },
    );
  }

  void _startJourney(String busId) {
    // flutter defined function
    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(AppLocalizations.of(context).translate('bus_list_start_title')+busId),//Text("Start location share for bus: busId?"),
          content: new Text(
              AppLocalizations.of(context).translate('bus_list_start_msg')+busId),//"Are you travelling with on line: busId?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context).translate('yes')),//Text("yes"),
              onPressed: () {
                setState(() {
                  gMyBusId = busId;
                  BackgroundFetch.start().then((int status) {
//                    print('[BackgroundFetch] start success: $status');
                  }).catchError((e) {
//                    print('[BackgroundFetch] start FAILURE: $e');
                  });
                  actualLine = gLineList.firstWhere((Line l) {
                    return l.lineId.toString() == busId;
                  }, orElse: () => null);
                  if (!gDrivingDetector.isStarted)
                    gDrivingDetector.startDrivingDetection();
                  appBloc.updateTitle();
                  appBloc.updateFab();
                  Navigator.of(context).pop();
                  tabController.animateTo(1);
                });
              },
            ),
            new FlatButton(
              child: new Text(AppLocalizations.of(context).translate('nope')),//Text(no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

}