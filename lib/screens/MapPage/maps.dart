import 'dart:async';
import 'dart:collection';
import 'package:bus_project/models/line.dart';
import 'package:bus_project/models/station.dart';
import 'package:bus_project/models/timetable.dart';
import 'package:bus_project/models/trace.dart';
import 'package:bus_project/screens/Shared/start.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:bus_project/screens/BusListPage/bus_list.dart';
import 'package:bus_project/services/communication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Shared/list.dart';
import 'package:flutter/scheduler.dart';
import 'package:bus_project/models/bus_data.dart';
import 'package:flutter_map/flutter_map.dart';


class Maps extends StatefulWidget {
  final Todo todo;

  @override
  MapsFlutter createState() => new MapsFlutter(todo);

  Maps([this.todo]);
}



class MapsFlutter extends State<Maps> with TickerProviderStateMixin {
  Todo todo;
  List<Marker> markers;
  List<Polyline> polyLines;
  List<CircleMarker> circleMarkers;
  Timer _timer;
  MapController mapController;
  int selectedLayer = 0;
  bool toggleBus = true;
  bool toggleStation = false;
  bool toggleLine = false;
  String selectedBusId = "Off";


  MapsFlutter([this.todo]);

  // Called once when the stateful widget is inserted in the widget tree.
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    gGeoPosition.getLocation();

    if (todo != null)
      SchedulerBinding.instance.addPostFrameCallback((_) => _animatedMapMove(
          LatLng(todo.actualLatitude, todo.actualLongitude), 17.0));

    if (circleMarkers == null) circleMarkers = List<CircleMarker>();
  }



  LayerOptions filterStations() {
    bool blue = false;
    // bool notFirst = false;
    Line selectedLine;
    List<int> endStationsOfSelectedBus;
    List<Station> filteredStationList;

    // There is no selected bus.
    if(selectedBusId != "Off") {
      if (gLineList != null) {

        // selectedLine Line variable contains the lineId and the list of stations of a selected bus
        selectedLine = gLineList.singleWhere( (element) => element.lineId == selectedBusId, orElse: () => null);


        if (selectedLine != null && selectedLine.stationList.length != 0) {

          // vTimetable list contains the timetable of the selected bus
          List<Timetable> vTimetable = gTimetable.where((element) => element.busNr == selectedBusId).toList();

          // endStationsOfSelectedBus contains the terminals of a selected line
          endStationsOfSelectedBus = vTimetable.map((table) { return table.stationID; }).toList();

          // Remove duplicates and sort the list.
          endStationsOfSelectedBus = LinkedHashSet<int>.from(endStationsOfSelectedBus).toList();
          endStationsOfSelectedBus.sort();


          // gStationList contains the list of stations of a selected line
          // filteredStationList contains the list of stations of a selected line
          filteredStationList = selectedLine.stationList.map((entry) {
            return gStationList.firstWhere((st){return st.stationId == entry.stationId.toString();});
          }).toList();
          print(filteredStationList);


          // Map markers.
          markers = filteredStationList.map((element) {
            // if (notFirst && endLines.contains(station.stationId)) { blue = false; }
            // notFirst = true;
            return blue?Marker(
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

            ):Marker(
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
          return new MarkerLayerOptions(markers: markers);
        }
        else{
          print('dick');
        }
      }
    }
    return new MarkerLayerOptions(markers: []);
  }



  LayerOptions switchLayers() {
    markers = null;
    if (circleMarkers != null)
      circleMarkers.clear(); //<-This might be dangerous...

    if (selectedLayer == 0) {
     print("LAYER SELECTED >> BUSES, maps.dart, line 128");
      markers = updateMarkers();
      if (_timer == null) {
        _timer = Timer.periodic(Duration(seconds: 30), (_) async {
          BusInformationListPost temp = await getBusInformationList();
          gBusList = temp.busList;
          circleMarkers.clear();
          setState(() {
            markers = updateMarkers();

            //It is called two times.
          });
        });
      }
    }
    else if (selectedLayer == 1) {
      print("Layer selected >> LINES, maps.dart, line 143");
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
      polyLines = new List<Polyline>();
      markers = null;

      if(selectedBusId != "Off") {
        polyLines.add(linesDrawerFirstHalf());
        // polyLines.add(linesDrawerLastHalf());
      }
    }
    if (markers != null) {
      return new MarkerLayerOptions(markers: markers);
    } else {
      return new PolylineLayerOptions(polylines: polyLines);
    }
  }


  // Draw the first half of the route on the map from BusTrace table.
  Polyline linesDrawerFirstHalf() {
    List<LatLng> tempLinePoints = new List<LatLng>();
    Trace line;
    if (gTraceList != null) {
      line = gTraceList.singleWhere((o) => o.lineId.toString() == selectedBusId, orElse: () => null);
      if(line != null && line.pointList.length != 0) {
        int half = (line.pointList.length/2).floor();
        tempLinePoints = line.pointList.sublist(0, half + 1).map((poi) {
          return new LatLng(poi.latitude, poi.longitude);
        }).toList();
      }
    }
//    print('$temp3, maps.dart, line 174');
    return Polyline(points: tempLinePoints, strokeWidth: 4.0, color: Colors.blue);
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
// //    print('$temp3 maps.dart, line 191');
//     return Polyline(points: temp3, strokeWidth: 4.0, color: Colors.purple);
//   }

  List<Marker> updateMarkers() {
    List<Marker> vTempMarker;
    if (gBusList != null) {
      // print(gBusList);

      // vTempMarker = gBusList.map((bus) {
      //   vTempMarker.add(new Marker(
      //     width: 30.0,
      //     height: 30.0,
      //     point: new LatLng(bus.actualLatitude, bus.actualLongitude),
      //     builder: (ctx) => Container(
      //       // key: Key('purple'),
      //       child: new CircleAvatar(
      //           foregroundColor: Colors.white,
      //           backgroundColor: Colors.blue,
      //           // (bus.pointsNearby>=0)?Colors.green:Colors.amber,
      //           child: new Text(bus.busId)),
      //     ),
      //   ));
      // }).toList();
      vTempMarker = gBusList.map((bus) {
        return Marker(
          width: 30.0,
          height: 30.0,
          point: new LatLng(bus.actualLatitude, bus.actualLongitude),
          builder: (ctx) => Container(
            key: Key('purple'),
            child: new CircleAvatar(
                foregroundColor: Colors.white,
                // backgroundColor: Colors.blue,
                backgroundColor: (bus.pointsNearby != null)?Colors.green:Colors.amber,
                child: new Text(bus.busId)),
          ),
        );
      }).toList();

      // Location of user
      if (gGeoPosition.userLocation != null) {
        /// SET TIMER IF THERE IS A USER LOCATION
        if(gMyBusId == null) {
          vTempMarker.add(new Marker(
            width: 30.0,
            height: 30.0,
            point: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
            builder: (ctx) => new Container(
              child: Icon(
                  MdiIcons.mapMarker,
                  color: Colors.blueGrey
              ),
            ),
          ));
        }else{
          vTempMarker.add(new Marker(
            width: 30.0,
            height: 30.0,
            point: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
            builder: (ctx) => new Container(
              child: new CircleAvatar(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  child: new Text(gMyBusId)),
            ),
          ));
        }
        circleMarkers = <CircleMarker>[
          CircleMarker(
              point: new LatLng(gGeoPosition.userLocation.latitude,
                  gGeoPosition.userLocation.longitude),
              color: Colors.blue.withOpacity(0.4),
              useRadiusInMeter: true,
              radius: (range * 1000)
          ),
        ];
      }
    }
    return vTempMarker;
  }

  List<Marker> stationMarkers() {
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
          point: new LatLng(gGeoPosition.userLocation.latitude,
              gGeoPosition.userLocation.longitude),
          builder: (ctx) => new Container(
            child: Icon(
              MdiIcons.mapMarker,
              color: Colors.blueGrey,
            ),
          ),
        ));
        circleMarkers = <CircleMarker>[
          CircleMarker(
              point: new LatLng(gGeoPosition.userLocation.latitude,
                  gGeoPosition.userLocation.longitude),
              color: Colors.blue.withOpacity(0.4),
              useRadiusInMeter: true,
              radius: (range * 1000)
          ),
        ];
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
//      print('$status maps.dart, line 342');
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
    double buttonSize = ((MediaQuery.of(context).size.width-20)/4);
    var list = gBusDataList.map((var value) {
      return new DropdownMenuItem<String>(
        value: value.busId,
        child: new ListTile(
          leading: new CircleAvatar(
              foregroundColor: Colors.white,
              backgroundColor: (value.busId == gMyBusId)?Colors.red:Colors.blue,
              child: new Text(value.busId)),
          title: Text(value.busName),
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
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[



                  // Start journey button
                  new SizedBox(
                    width: buttonSize,//80.0,
                    child: RaisedButton(
                      child: (gMyBusId==null)?Text(AppLocalizations.of(context).translate('map_btn_start_journey')):Text(gMyBusId),//Text('Center'),
                      highlightColor: gMyBusId==null?Color(0xFF42A5F5):Colors.redAccent,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side: BorderSide(color: gMyBusId==null?Colors.blue:Colors.red)),
                      textColor: gMyBusId==null?Colors.blue:Colors.red,
                      color: Colors.white70,
                      onPressed: () {
                        if(gMyBusId==null)
                          tabController.animateTo(0);
                      },
                    ),
                  ),



                  // Buses button
                  new SizedBox(
                    width: buttonSize,
                    // Buses button
                    child: RaisedButton(
                      autofocus: true,
                      child: Text(AppLocalizations.of(context).translate('map_btn_bus').toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),),
                      highlightColor: Color(0xFF42A5F5),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side: BorderSide(color: toggleBus ? Colors.white : Colors.blue)),
                      textColor: toggleBus ? Colors.white : Colors.blue,
                      color: toggleBus ? Colors.blue : Colors.white70,
                      onPressed: () {
//                              print("Buses Pressed, maps.dart, line 427");
                        setState(() {
                          selectedLayer = 0;
                          toggleBus = true;
                          toggleLine = false;
                          toggleStation = false;
                        },);},),),



                  // Lines button
                  // A box with a specified size.
                  new SizedBox(
                    width: buttonSize,
                    // Lines button.
                    child: RaisedButton(

                      child: Text(AppLocalizations.of(context).translate('map_btn_lines').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      highlightColor: Color(0xFF42A5F5),

                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side: BorderSide(color: toggleLine ? Colors.white : Colors.blue)),

                      textColor: toggleLine ? Colors.white : Colors.blue,
                      color: toggleLine ? Colors.blue : Colors.white70,
                      onPressed: () {
                        print("Lines Pressed, maps.dart, line 455");
                        setState(() {
                          selectedLayer = 1;
                          toggleBus = false;
                          toggleLine = true;
                          toggleStation = false;
                        },);},),),



                  // Center button
                  new SizedBox(
                    width: buttonSize,
                    child: RaisedButton(
                      child: Text(AppLocalizations.of(context).translate('map_btn_center')),
                      highlightColor: Color(0xFF42A5F5),

                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(180.0),
                          side: BorderSide(color: Colors.blue)),

                      textColor: Colors.blue,
                      color: Colors.white70,

                      onPressed: () {
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
                          ),);},),),

                ],
              ),
            ),


            // Child: dropdown list
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

              visible: toggleLine,
            ),


            // Map child
            Flexible(
              child: FlutterMap(
                mapController: mapController,
                options: new MapOptions(
                  center: new LatLng(gGeoPosition.userLocation.latitude, gGeoPosition.userLocation.longitude),
                  // center: new LatLng(46.53, 24.56),
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
                ],),),
          ],
        ),
      ),
    );
  }
}
