import 'dart:async';
import 'dart:collection';
import 'package:bus_project/assets/icon/bus_icons.dart';
import 'package:bus_project/models/station_on_line.dart';
import 'package:bus_project/models/station.dart';
import 'package:bus_project/models/timetable.dart';
import 'package:bus_project/models/trace.dart';
import 'package:bus_project/screens/Shared/start.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:bus_project/screens/BusListPage/bus_list.dart';
import 'package:bus_project/services/communication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Shared/list.dart';
import 'package:flutter/scheduler.dart';
import 'package:bus_project/models/course_data.dart';
import 'package:flutter_map/flutter_map.dart';
import "dart:math" show pi;
import "dart:math" show sin;
import "dart:math" show cos;
import "dart:math" show atan2;
import "dart:math" show sqrt;

class Map extends StatefulWidget {
  final Todo todo;

  @override
  MapsFlutter createState() => new MapsFlutter(todo);
  Map([this.todo]);
}



class MapsFlutter extends State<Map> with TickerProviderStateMixin {

  degreesToRadians(degrees){
    return degrees * pi / 180;
  }

  getDistanceBetweenPoints(lat1, lng1, lat2, lng2) {
  int R = 6378137;

  double dLat = degreesToRadians(lat2 - lat1);
  double dLong = degreesToRadians(lng2 - lng1);

  double a = sin(dLat / 2) * sin(dLat / 2) + cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat1)) * sin(dLong / 2) * sin(dLong / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = R * c;

  return distance;
}

  Todo todo;
  List<Marker> userLocationMarker = List<Marker>();
  // List<Marker> stationMarkers = List<Marker>();
  // List<Marker> busMarkers = List<Marker>();
  List<Polyline> polyLines;
  List<CircleMarker> circleMarkers = List<CircleMarker>();
  Timer _timer;
  MapController mapController;
  int selectedLayer = 0;
  bool toggleBus = true;
  bool toggleStation = false;
  bool toggleLine = false;
  String selectedBusId = "Off";
  MapsFlutter([this.todo]);
  int dropdownValue = 2;



  // Called once when the stateful widget is inserted in the widget tree.
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    gGeoPosition.getLocation();

    if (todo != null)
      SchedulerBinding.instance.addPostFrameCallback((_) => _animatedMapMove(
          LatLng(todo.actualLatitude, todo.actualLongitude), 17.0));

    // if (circleMarkers == null) circleMarkers = List<CircleMarker>();
  }


  // A felhasználó helyadataival kapcsolatos markerek kezelése.
  LayerOptions permanentMarkers() {

    // A listát törölni kell mindig, nehogy több marker is megjelenjen benne.
    userLocationMarker.clear();

    // Ha a felhasználó megosztja a helyadatait.
    if (gGeoPosition.userLocation != null) {
      // TODO: SET TIMER IF THERE IS A USER LOCATION

      // Ha a felhasználó osztja a helyadatokat, de nem utazik busszal.
      if (gMyBusId == null ) {
        userOnBus.lineId = '-1';
        userLocationMarker.add(new Marker(
          point: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
          builder: (ctx) =>
          new Container(
            child: Icon(
                MdiIcons.mapMarker,
                color: Colors.blueGrey
            ),
          ),
        ));
      }

      // Ha a felhasználó egy kiválasztott busszal utazik.
      else {
        userLocationMarker.add(new Marker(
          width: 30.0,
          height: 30.0,
          point: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
          builder: (ctx) => new Container(
            child: new CircleAvatar(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                child: new Text(gMyBusId)
            ),
          ),
        ));
      }

      return new MarkerLayerOptions(markers: userLocationMarker);
    }

    userOnBus.lineId = '-1';
    return new MarkerLayerOptions(markers: []);
  }



  LayerOptions filterStations() {
    if(selectedBusId != "Off" && stationOnLineListGlobal != null) {
      // bool notFirst = false;

      StationOnLine selectedLineWithStations = stationOnLineListGlobal.singleWhere( (e) => e.lineId == selectedBusId, orElse: () => null);


      if (selectedLineWithStations != null && selectedLineWithStations.lineData.length != 0) {

        List<Timetable> vTimetable = timetableListGlobal.where((e) => e.lineId == selectedBusId).toList();
        
        List<int> terminusOfSelectedLine = vTimetable.map((table) { return table.stationID; }).toList();

        terminusOfSelectedLine = LinkedHashSet<int>.from(terminusOfSelectedLine).toList();
        terminusOfSelectedLine.sort();


        List<Station> filteredStationList = selectedLineWithStations. lineData.map((e) {
          return gStationList.firstWhere((st){return st.id == e.stationId.toString();});
        }).toList();


        // Map markers.
        List<Marker> stationMarkers = List<Marker>();
        stationMarkers = filteredStationList.map((element) {
          // if (notFirst && endLines.contains(station.stationId)) { blue = false; }
          // notFirst = true;
          bool blue = false;
          return blue ? Marker(
            // width: 40.0,
            // height: 40.0,
            point: new LatLng(element.latitude, element.longitude),

            builder: (ctx) =>
                Container(
                    key: Key('green'),
                    child: IconButton(
                        icon: Icon(
                          MdiIcons.mapMarker,
                          color: Colors.deepOrange,
                          size: 40.0,),
                        onPressed: () {
                          Scaffold.of(currentContext).showSnackBar(
                              new SnackBar(
                                content: Text(element.stationName),
                              ));})),

            // Markers of stations.
          ) : Marker(
            // width: 40.0,
            // height: 40.0,
            point: new LatLng(element.latitude, element.longitude),
            builder: (ctx) =>
                Container(
                    key: Key('green'),
                    child: IconButton(
                        icon: Icon(MdiIcons.mapMarker,
                          color: Colors.yellow,
                          // size: 40.0,

                        ),
                        //color: Colors.white,
                        onPressed: () {
                          Scaffold.of(currentContext).showSnackBar(
                              new SnackBar(
                                content: Text(element.stationName),
                              ));})),);
        }).toList();
        return new MarkerLayerOptions(markers: stationMarkers);
      }
    }
    return new MarkerLayerOptions(markers: []);
  }




  LayerOptions filterBuses() {
    bool blue = false;
    StationOnLine selectedLine;
    List<int> endStationsOfSelectedBus;
    List<Station> filteredStationList;

    // There is no selected bus.
    if(selectedBusId != "Off") {
      List<Marker> stationMarkers = List<Marker>();

      if (stationOnLineListGlobal != null) {

        // selectedLine Line variable contains the lineId and the list of stations of a selected bus
        selectedLine = stationOnLineListGlobal.singleWhere( (element) => element.lineId == selectedBusId, orElse: () => null);


        if (selectedLine != null && selectedLine.lineData.length != 0) {

          // vTimetable list contains the timetable of the selected bus
          List<Timetable> vTimetable = timetableListGlobal.where((element) => element.lineId == selectedBusId).toList();

          // endStationsOfSelectedBus contains the terminals of a selected line
          endStationsOfSelectedBus = vTimetable.map((table) { return table.stationID; }).toList();

          // Remove duplicates and sort the list.
          endStationsOfSelectedBus = LinkedHashSet<int>.from(endStationsOfSelectedBus).toList();
          endStationsOfSelectedBus.sort();


          // gStationList contains the list of stations of a selected line
          // filteredStationList contains the list of stations of a selected line
          filteredStationList = selectedLine.lineData.map((entry) {
            return gStationList.firstWhere((st){return st.id == entry.stationId.toString();});
          }).toList();


          // Map markers.
          stationMarkers = filteredStationList.map((element) {
            // if (notFirst && endLines.contains(station.stationId)) { blue = false; }
            // notFirst = true;
            return blue ? Marker(
              // width: 40.0,
              // height: 40.0,
              point: new LatLng(element.latitude, element.longitude),

              builder: (ctx) =>
                  Container(
                      key: Key('green'),
                      child: IconButton(
                          icon: Icon(
                            MdiIcons.mapMarker,
                            color: Colors.deepOrange,
                            size: 40.0,),
                          onPressed: () {
                            Scaffold.of(currentContext).showSnackBar(
                                new SnackBar(
                                  content: Text(element.stationName),
                                ));})),

              // Markers of stations.
            ) : Marker(
              // width: 40.0,
              // height: 40.0,
              point: new LatLng(element.latitude, element.longitude),
              builder: (ctx) =>
                  Container(
                      key: Key('green'),
                      child: IconButton(
                          icon: Icon(MdiIcons.mapMarker,
                            color: Colors.yellow,
                            // size: 40.0,

                          ),
                          //color: Colors.white,
                          onPressed: () {
                            Scaffold.of(currentContext).showSnackBar(
                                new SnackBar(
                                  content: Text(element.stationName),
                                ));})),);
          }).toList();
          return new MarkerLayerOptions(markers: stationMarkers);
        }
      }
    }
    return new MarkerLayerOptions(markers: []);
  }







  // Buses layer.
  LayerOptions switchLayers() {
    if (selectedLayer == 0) {
      List<Marker> busMarkers = List<Marker>();
      busMarkers = updateMarkers();

      if (_timer == null) {
        _timer = Timer.periodic(Duration(seconds: 2), (_) async {

          try{
            BusDataListPost temp = await getBusDataList();
            courseDataGlobal = temp.busList;
          }catch(error){
            print('Caught error: $error');
          }
          setState(() {
            busMarkers = updateMarkers();
          });
        });
      }
      return new MarkerLayerOptions(markers: busMarkers);
    }
    else if (selectedLayer == 1) {
      polyLines = new List<Polyline>();

      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
      if (selectedBusId != "Off") {
        polyLines.add(linesDrawerFirstHalf());
        // polyLines.add(linesDrawerLastHalf());
      }
      return new PolylineLayerOptions(polylines: polyLines);
    }
    else{return new MarkerLayerOptions(markers: []);}
  }


  // Draw the first half of the route on the map from BusTrace table.
  Polyline linesDrawerFirstHalf() {
    List<LatLng> tempLinePoints = new List<LatLng>();
    Trace line;
    if (gTraceList != null) {
      line = gTraceList.singleWhere((e) => e.lineId.toString() == selectedBusId, orElse: () => null);
      if(line != null && line.pointList.length != 0) {
        int half = (line.pointList.length).floor();
        tempLinePoints = line.pointList.sublist(0, half).map((poi) {
          return new LatLng(poi.latitude, poi.longitude);
        }).toList();
      }
    }
    else{
    }
    return Polyline(points: tempLinePoints, strokeWidth: 9.0, color: Colors.red);
  }

  // Draw the second half of the route on the map from BusTrace table.
//   Polyline linesDrawerLastHalf() {
//     List<LatLng> temp3 = new List<LatLng>();
//     Trace line;
//     if (gTraceList != null) {
//       line = gTraceList.singleWhere((o) => o.lineId.toString() == selectedBusId, orElse: () => null);
//       if(line != null || line.pointList.length != 0) {
//         int half=(line.pointList.length/2).floor();
//         temp3 = line.pointList.sublist(half).map((poi) {
//           return new LatLng(poi.latitude, poi.longitude);
//         }).toList();
//       }
//     }
//
//     return Polyline(points: temp3, strokeWidth: 4.0, color: Colors.purple);
//   }


  // Ez a függvény frissíti a buszokat jelző markereket a térképen.
  List<Marker> updateMarkers() {

    // Ha a felhasználó kiválaszt egy buszt.
    print(courseDataGlobal == null);
    if(selectedBusId != 'Off' && courseDataGlobal != null && courseDataGlobal.length != 0) {

      List<Marker> markersTemp = List<Marker>();

      List<CourseData> busList = courseDataGlobal.map((e) => e).toList();
      busList.removeWhere((element) => element.lineId != selectedBusId);

      // Csak az egyik irányba közlekedő buszok.
      List<CourseData> busListOnDirection = busList.map((e) => e).toList();
      busListOnDirection.removeWhere((element) => element.direction != userOnBus.direction);


      // Ha a felhasználó egy adott busszal utazik.
      if(userOnBus.lineId != '-1' && busListOnDirection.length != 0) {
        List<CourseData> busListTemp2 = busList.map((e) => e).toList();

        // Az első busszal lévő távolságot beállítja minimumnak.
        double minDistance = 10000;
        // getDistanceBetweenPoints(busListTemp2[0].latitude, busListTemp2[0].longitude, userOnBus.latitude, userOnBus.longitude);
        int positionTemp = -1;

        // Majd az összess elemmel kiszámolja a távolságot és kiválasztja a valós minimumot.
        // Az elemnek lementjük a pozicióját.
        for(int i = 0; i < busListTemp2.length; ++i){

          if(busListTemp2[i].direction == userOnBus.direction) {
            double minDistanceTemp = getDistanceBetweenPoints(busListTemp2[i].latitude, busListTemp2[i].longitude, userOnBus.latitude, userOnBus.longitude);

            if(minDistanceTemp < minDistance){
              positionTemp = i;
            }
          }
        }

        if(positionTemp != -1) {
          busList.removeAt(positionTemp);
        }
      }


      markersTemp = busList.map((e) {
        return Marker(
          point: new LatLng(e.latitude, e.longitude),
          builder: (ctx) => Container(
            child: new CircleAvatar(
                foregroundColor: Colors.white,
                child: new Text(e.lineId)),
          ),
        );
      }).toList();


      // A felhasználó helye.
      if (gGeoPosition.userLocation != null) {
        // circleMarkers = <CircleMarker>[
        //   CircleMarker(
        //       point: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
        //       color: Colors.blue.withOpacity(0.4),
        //       useRadiusInMeter: true,
        //       radius: (gRangeInKilometer * 1000)
        //   ),
        // ];
      }
      return markersTemp;
    }
    return [];
  }



  List<Marker> stationMarkersF() {
    List<Marker> temp2;
    if (gStationList != null) {
      temp2 = gStationList.map((station) {
        return Marker(
          width: 40.0,
          height: 40.0,
          point: new LatLng(station.latitude, station.longitude),
          builder: (ctx) => Container(
              key: Key('green'),
              child: IconButton(
                  icon: Icon( MdiIcons.mapMarker,
                    color: Colors.black,
                    size: 40.0,),
                  onPressed: () { Scaffold.of(currentContext).showSnackBar(new SnackBar(//_scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text(station.stationName),
                  ));}
              )),
        );
      }).toList();

      if (gGeoPosition.userLocation != null) {

        temp2.add(new Marker(
          width: 30.0,
          height: 30.0,
          point: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
          builder: (ctx) => new Container(
            child: Icon(
              MdiIcons.mapMarker,
              color: Colors.blueGrey,
            ),
          ),
        ));
        // circleMarkers = <CircleMarker>[
        //   CircleMarker(
        //       point: new LatLng(gGeoPosition.userLocation.latitude,
        //           gGeoPosition.userLocation.longitude),
        //       color: Colors.blue.withOpacity(0.4),
        //       useRadiusInMeter: true,
        //       radius: (gRangeInKilometer * 1000)
        //   ),
        // ];
      }
    }
    return temp2;
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }



  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }



  @override
  Widget build(BuildContext context) {
    currentContext = context;
    // double buttonSize = ((MediaQuery.of(context).size.width-20)/4);

    var list = lineListGlobal.map((var value) {
      return new DropdownMenuItem<String>(
        // value: value.id,
        value: value.id,
        child: new ListTile(
          leading: new CircleAvatar(
              foregroundColor: Colors.white,
              backgroundColor: (value.id == gMyBusId) ? Colors.red:Colors.blue,
              child: new Text(value.id)),
          title: Text(value.id),
        ),
      );
    }).toList();

    list.add(new DropdownMenuItem<String>(
      value: 'Off',
      child: new Text(AppLocalizations.of(context).translate('off'),
        style: TextStyle(
            fontStyle: FontStyle.italic
        ),
      ),
    ));

    return (gGeoPosition.userLocation == null)
        ? Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()])))



        : Scaffold(
      body: Column(
          children: [
            // Az oszlop modul első
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // A sor modul első eleme.
                DropdownButton(
                    value: dropdownValue,
                    items: [
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_start_journey'),
                        ),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_bus')),
                        value: 2,
                      ),
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_lines')),
                        value: 3,
                      ),
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_center')),
                        value: 4,
                      )
                    ],
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if(value == 1){
                          if(gMyBusId == null)
                            tabController.animateTo(0);
                        }
                        if(value == 2){
                          selectedLayer = 0;
                          toggleBus = true;
                          toggleLine = false;
                          toggleStation = false;
                        }
                        if(value == 3){
                          selectedLayer = 1;
                          toggleBus = false;
                          toggleLine = true;
                          toggleStation = false;
                        }
                        if(value == 4){
                          var bounds = LatLngBounds();
                          bounds.extend(
                            new LatLng(gGeoPosition.userLocation.latitude,
                                gGeoPosition.userLocation.longitude),
                          );
                          mapController.fitBounds(
                            bounds,
                            options: FitBoundsOptions(
                              padding:
                              EdgeInsets.only(left: 15.0, right: 15.0),
                            ),);
                          value = dropdownValue;
                        }
                        dropdownValue = value;
                      });
                    },
                  ),

                // A sor modul második eleme.
                // TODO: Itt ki kell lehessen választani az adott vonal irányát.
                Visibility(
                  child: DropdownButton(
                    value: dropdownValue,
                    items: [
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_start_journey'),
                        ),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_bus')),
                        value: 2,
                      ),
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_lines')),
                        value: 3,
                      ),
                      DropdownMenuItem(
                        child: Text(AppLocalizations.of(context).translate('map_btn_center')),
                        value: 4,
                      )
                    ],
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if(value == 1){
                          if(gMyBusId == null)
                            tabController.animateTo(0);
                        }
                        if(value == 2){
                          selectedLayer = 0;
                          toggleBus = true;
                          toggleLine = false;
                          toggleStation = false;
                        }
                        if(value == 3){
                          selectedLayer = 1;
                          toggleBus = false;
                          toggleLine = true;
                          toggleStation = false;
                        }
                        if(value == 4){
                          var bounds = LatLngBounds();
                          bounds.extend(
                            new LatLng(gGeoPosition.userLocation.latitude,
                                gGeoPosition.userLocation.longitude),
                          );
                          mapController.fitBounds(
                            bounds,
                            options: FitBoundsOptions(
                              padding:
                              EdgeInsets.only(left: 15.0, right: 15.0),
                            ),);
                          value = dropdownValue;
                        }
                        dropdownValue = value;
                      });
                    },
                  ),
                    visible: toggleLine == true ? true : false
                ),
              ],
            ),


            // Lenyíló lista: Alapértelmezett: Kikapcsolva
            Visibility(
              child:new DropdownButton<String>(
                isExpanded: true,
                value: selectedBusId == "Off" ? 'Off' : selectedBusId,
                items: list.reversed.toList(),
                onChanged: (newVal) {
                  setState(() {
                    if (newVal == 'Off') {
                      selectedBusId = "Off";
                    } else {
                      selectedBusId = newVal;
                    }},);},),

              visible: toggleBus || toggleLine,
            ),


            // Gyermek modul: Térkép
            Flexible(
              child: FlutterMap(
                mapController: mapController,
                options: new MapOptions(
                  // center: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
                  center: new LatLng(46.53, 24.56),
                  zoom: 18.0,
                ),

                layers: [
                  new TileLayerOptions(
                    urlTemplate:
                    // Streets view of map.
                    'https://api.mapbox.com/styles/v1/geergely-zsolt/ckfgpaks82fqe19pnlit6xbby/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ2VlcmdlbHktenNvbHQiLCJhIjoiY2tkdHNqbmxqMWw5MTMwb2R0djcxMXdrcSJ9.FjR4wOzpMGOb2jKx0YxLHA',

                    additionalOptions: {
                      'accessToken': 'pk.eyJ1IjoiZ2VlcmdlbHktenNvbHQiLCJhIjoiY2tkdHNqbmxqMWw5MTMwb2R0djcxMXdrcSJ9.FjR4wOzpMGOb2jKx0YxLHA',
                      'id': 'mapbox.mapbox.streets-v8',
                    },),
                  switchLayers(),
                  filterStations(),
                  permanentMarkers()
                  // filterBuses(),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
