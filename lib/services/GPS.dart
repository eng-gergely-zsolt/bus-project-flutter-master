import 'dart:async';
import 'dart:math';
import 'package:background_fetch/background_fetch.dart';
import 'package:bus_project/models/station.dart';
import 'package:bus_project/screens/Shared/list.dart';
import 'package:bus_project/services/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'AppPropertiesBLoC.dart';
import 'communication.dart';

class GPS {
  static final GPS _instance = GPS._internal();

  factory GPS() => _instance;
  Geolocator geolocator;
  Stream<Position> stream;
  StreamSubscription locationSubscription;
  Position userLocation;
  LocationAccuracy accuracy = LocationAccuracy.bestForNavigation;
  int timeInt = 30000;
  int distance = 1;
  bool questionSent = false;

  GPS._internal() {
//    print("START GPS DETECTION");
    geolocator = Geolocator();
    if (stream == null) {
      stream = geolocator.getPositionStream(LocationOptions(
          accuracy: accuracy, timeInterval: timeInt, distanceFilter: distance));
      geolocator.isLocationServiceEnabled().then((s) {
        if (!s) {
          _askForLocationServices();
        }
      });
      getPositionStream();
    }
  }

  void getPositionStream() {
    locationSubscription = stream.listen((position) {
      userLocation = position;
      //print(userLocation);
      //print(ServerClientDifference);
      List<Station> nearbyStations = new List<Station>.from(gStationList);

      bool detected = false;
      print("nearbyStations before retainWhere");
      print(nearbyStations);

      double min = 100.0;
      String vStationName = "";
      nearbyStations.retainWhere((item) {
        double dist = distanceInKmBetweenEarthCoordinates(userLocation.latitude,
            userLocation.longitude, item.latitude, item.longitude);

        if(dist < min){
          min = dist;
          vStationName = item.stationName;
        }

        if (dist <= gRangeInKilometer) {
          detected = true;
          return true;
        }
        return false;
      });

      // print("nearbyStations after retainWhere - line 63");
      // print(nearbyStations);

      if (detected) {
        gNearStation = true;
        gStationText = AppLocalizations.of(currentContext).translate('gps_you_are_at') + vStationName; // You are at
        getArrivalTimeList(int.parse(nearbyStations.first.stationId)).then((val) => gArrivalTimeList = val.arrivalTimeList);
        print("gArrivalTimeList: ");
        print(gArrivalTimeList);
      } else {
        gNearStation = false;
        gStationText = AppLocalizations.of(currentContext).translate('settings_no_station'); // No stations nearby

        if (gArrivalTimeList != null && gArrivalTimeList.length > 0)
          gArrivalTimeList.clear();
      }

      if (gMyBusId != null) {
        if (gDrivingDetector.drivingScore >= 40) {
          var post = {
            'BusId': gMyBusId,
            'Actual_Latitude': userLocation.latitude,
            'Actual_Longitude': userLocation.longitude,
            'Position_Accuracy': userLocation.accuracy,
            'Actual_Speed': userLocation.speed,
            'Speed_Accuracy': userLocation.speedAccuracy,
            'Direction': userLocation.heading,
            'Acceleration': gDrivingDetector.accelerometerValues,
            'Gyroscope': gDrivingDetector.gyroscopeValues,
            'Timestamp': DateTime.now()
                .add(gServerClientDifference)
                .toString()
                .split(".")[0]
          };
          //print(post);
          postBusInformationTest(post);//Uncomment when needed.
        } else {
          if (!questionSent) {
            questionSent = true;
            Timer(Duration(seconds: 60), () {
              if (gDrivingDetector.drivingScore < 40 &&
                  !gDrivingDetector.activeSubscription.isPaused) {
                _showQuestion();
              }
            });
          }
        }
      }
    });
    getLocation();
  }

  void sendPositionOnce(){
    _getLocation().then((position) {
      userLocation = position;
//      print("/*/*/*/SENDING DATA TO SERVER");
      if (gMyBusId != null && gServerClientDifference !=  null) {
        if (gDrivingDetector.drivingScore >= 40) {
          var post = {
            'BusId': gMyBusId,
            'Actual_Latitude': userLocation.latitude,
            'Actual_Longitude': userLocation.longitude,
            'Position_Accuracy': userLocation.accuracy,
            'Actual_Speed': userLocation.speed,
            'Speed_Accuracy': userLocation.speedAccuracy,
            'Direction': userLocation.heading,
            'Acceleration': gDrivingDetector.accelerometerValues,
            'Gyroscope': gDrivingDetector.gyroscopeValues,
            'Timestamp': DateTime.now()
                .add(gServerClientDifference)
                .toString()
                .split(".")[0]
          };
          postBusInformationTest(post);
//          print("/*/*/*/DATA SENT");
        }
      }
    });
  }

  void dispose() {
//    print("DESTROY GPS DETECTION");
    locationSubscription.cancel();
  }

  void _showQuestion() {
    // flutter defined function
    if (gMyBusId != null)
      showDialog(
        barrierDismissible: false,
        context: currentContext,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(AppLocalizations.of(context).translate('gps_stop_location')),//Text("Stop location share?"),
            content:
            new Text(AppLocalizations.of(context).translate('gps_stop_location_msg')),//Text("Did you finish your travel? Or did something happen?"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text(AppLocalizations.of(context).translate('gps_stop_location_continue')),//Text("Continue"),
                onPressed: () {
                  questionSent = false;
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(AppLocalizations.of(context).translate('gps_stop_location_stop')),//Text("Stop"),
                onPressed: () {
                  gMyBusId = null;
                  questionSent = false;
                  nextStation = null;
                  actualStation = null;
                  actualLine = null;
                  gDrivingDetector.pauseDrivingDetection();
                  appBloc.updateTitle();
                  appBloc.updateFab();
                  BackgroundFetch.stop().then((int status) {
//                  print('[BackgroundFetch] stop success: $status');
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  }

  void _askForLocationServices() {
    // flutter defined function
    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(AppLocalizations.of(context).translate('location_service_title')),//Text("Location service is offline!"),
          content: new Text(
              AppLocalizations.of(context).translate('location_service_msg')),//"Please make sure you have enabled the Location Services on your phone"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context).translate('ok')),//Text("Ok"),
              onPressed: () {
                questionSent = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getLocation() async {
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  String longitude() {
    return userLocation.longitude.toString();
  }

  String latitude() {
    return userLocation.latitude.toString();
  }

  double degreesToRadians(degrees) {
    return degrees * PI / 180;
  }

  double distanceInKmBetweenEarthCoordinates(lat1, lon1, lat2, lon2) {
    var earthRadiusKm = 6371;

    var dLat = degreesToRadians(lat2 - lat1);
    var dLon = degreesToRadians(lon2 - lon1);

    lat1 = degreesToRadians(lat1);
    lat2 = degreesToRadians(lat2);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
