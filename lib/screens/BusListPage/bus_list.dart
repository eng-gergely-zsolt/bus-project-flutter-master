import 'package:background_fetch/background_fetch.dart';
import 'package:bus_project/models/bus_data.dart';
import 'package:bus_project/models/bus.dart';
import 'package:bus_project/models/station_on_line.dart';
import 'package:bus_project/models/line.dart';
import 'package:bus_project/screens/Shared/start.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:bus_project/services/AppPropertiesBLoC.dart';
import 'package:flutter/material.dart';
import 'package:bus_project/screens/Shared/list.dart';
import 'package:bus_project/screens/MapPage/map.dart';
import 'package:bus_project/services/communication.dart';
import 'timetable.dart';
class Todo {
  String busId;
  double actualLatitude;
  double actualLongitude;

  Todo(this.busId, this.actualLatitude, this.actualLongitude);
}

class BusList1 extends StatefulWidget {
  @override
  _BusListActionListener createState() => new _BusListActionListener();
}

class _BusListActionListener extends State<BusList1> {

  @override
  void initState() {
    super.initState();

    // if (gBusDataList == null) {
    //   getBusList().then((val) =>
    //       setState(() {
    //         gBusDataList = val.vBusList;
    //       }));
    // }


    // Ha épp nem közlekednek buszok, akkor ez a lista üres lesz.
    if (gBusList == null) {
      getBusDataList().then((val) =>
          setState(() {
            gBusList = val.busList;
          }));
    }


    if (gStationList == null) {
      getStationList().then((val) =>
          setState(() {
            gStationList = val.stationList;
          }));
    }


      if (lineListGlobal == null) {
        getLineList().then((val) =>
            setState(() {
              lineListGlobal = val.lineList;
            }));
      }


      // Ez minden alkalommal lefut, amikor a felhasználó
      // kiválasztja az Buses menüt, ha nincs az if feltétel.
      if (stationOnLineListGlobal == null) {
        try {
          getStationOnLineList().then((val) =>
              setState(() {
                stationOnLineListGlobal = val.stationOnlineList;
              }));
        } catch (e) {
          print('Error: bus_list.dart');
        }
      }


      if (gTraceList == null) {
        getLineTraceList().then((val) =>
            setState(() {
              gTraceList = val.traceList;
            }));
      }


      if (timetableListGlobal == null) {
        getTimetableList().then((val) =>
            setState(() {
              timetableListGlobal = val.timetableList;
            }));
      }


      if (gServerClientDifference == null) {
        synchronization().then((serverTime) {
//        print(serverTime);
          gServerClientDifference = DateTime.now()
              .difference(serverTime); //I guess this doesn't need refresh so...
//        print(ServerClientDifference);
        });
      }

      gGeoPosition.getLocation();
  }


 // CHANGED
  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return lineListGlobal == null
        ? Scaffold(
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()])))
        : ListView.builder(
      itemCount: lineListGlobal.length,
      itemBuilder: (context, index) {
        Line item = lineListGlobal[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          // ignore: missing_return
          confirmDismiss: (DismissDirection dir) {
            if (dir == DismissDirection.endToStart) {
              BusData bus = gBusList.firstWhere((x) {
                return lineListGlobal
                    .elementAt(index)
                    .id == x.busId;
              }, orElse: () => null);
              if (bus != null) {
                Todo coords = Todo(
                    bus.busId,
                    bus.latitude,
                    bus.longitude);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Map(coords),
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
                Text(AppLocalizations.of(context).translate('bus_list_show_map')),
                Icon(Icons.map),
              ],
            ),
            color: Colors.blue,
            alignment: Alignment.centerRight,
          ),
          child: ListTile(
            leading: new CircleAvatar(
                foregroundColor: Colors.white,
                backgroundColor: (item.id == gMyBusId) ? Colors.red : Colors.blue,
                child: new Text(lineListGlobal
                    .elementAt(index)
                    .id)),
            title: Text(lineListGlobal
                .elementAt(index)
                .id),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              _startJourney(lineListGlobal
                  .elementAt(index)
                  .id);
            },
            onLongPress: () {
              if (timetableListGlobal != null) {
                String busId = lineListGlobal
                    .elementAt(index)
                    .id;
                if (timetableListGlobal.firstWhere((o) => o.lineId == busId, orElse: () => null) != null)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimetableScreen(busId),
                    ),
                  );
              }
            },
          ),
        );
      },
    );
  }


  // Kigenerálja a kiválasztott vonal útvonalának neveit oda-vissza.
  void selectBusLine(List<Line> busLines, String selectedLineId) {

    Line selectedBusLine;
    String fromStartStationToEndStation;
    String fromEndStationToStartStation;

    selectedBusLine = busLines.firstWhere((element) => element.id == selectedLineId);

    fromStartStationToEndStation = selectedBusLine.startStationName.toString() + ' -> ' + selectedBusLine.endStationName.toString();
    fromEndStationToStartStation = selectedBusLine.endStationName.toString() + ' -> ' + selectedBusLine.startStationName.toString();

    routeNames.clear();
    routeNames.add(fromStartStationToEndStation);
    routeNames.add(fromEndStationToStartStation);
  }



  Future<String> _startJourney(String busId) {
    int _currentIndex = 0;
    selectBusLine(lineListGlobal, busId);
    return showDialog(
        context: currentContext,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState2) {
                return AlertDialog(
                    title: new Text(AppLocalizations.of(context).translate('bus_list_start_title') + busId), // Start location share for bus: busId
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(AppLocalizations.of(context).translate('yes')),
                        onPressed: () {
                          setState(() {
                            gMyBusId = busId;
                            BackgroundFetch.start().then((int status) {}).catchError((e) {});
                            actualLine = stationOnLineListGlobal.firstWhere((StationOnLine l) {
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
                        child: new Text(AppLocalizations.of(context).translate('nope')),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Are you travelling on line: busId?
                        new Text(AppLocalizations.of(context).translate('bus_list_start_msg') + busId + '?'),
                        Container(
                          width: double.minPositive,
                          height: 150,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 2,
                              itemBuilder: (BuildContext context, int index) {
                                return RadioListTile(
                                    value: index,
                                    groupValue: _currentIndex,
                                    title: Text(routeNames[index]),
                                    onChanged: (val) {
                                      setState2(() {
                                        _currentIndex = val;
                                        userOnBus.lineId = busId;
                                        userOnBus.direction = _currentIndex;
                                        userOnBus.latitude = gGeoPosition.userLocation.latitude;
                                        userOnBus.longitude = gGeoPosition.userLocation.longitude;
                                      });
                                    }
                                );
                              }
                          ),
                        )
                      ],
                    )
                );
              }
          );
        });
  }
}